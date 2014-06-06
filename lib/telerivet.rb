require 'net/http'
require 'json'
require_relative 'telerivet/entity'
require_relative 'telerivet/apicursor'

module Telerivet

#
# 
#
class API    
    attr_reader :num_requests

    @@client_version = '1.0.2'
    
    #
    # Initializes a client handle to the Telerivet REST API.
    # 
    # Each API key is associated with a Telerivet user account, and all
    # API actions are performed with that user's permissions. If you want to restrict the
    # permissions of an API client, simply add another user account at
    # <https://telerivet.com/dashboard/users> with the desired permissions.
    # 
    # Arguments:
    #   - api_key (Your Telerivet API key; see <https://telerivet.com/dashboard/api>)
    #       * Required
    #
    def initialize(api_key, api_url = 'https://api.telerivet.com/v1')
        @api_key = api_key
        @api_url = api_url
        @num_requests = 0
        @session = nil
    end

    public
    
    def do_request(method, path, params = nil)
        
        has_post_data = (method == 'POST' || method == 'PUT')

        url = @api_url + path
        
        if !has_post_data and params != nil && params.length > 0
            url += '?' + URI.encode_www_form(get_url_params(params))
        end
        
        uri = URI(url)
        
        if @session == nil            
            @session = Net::HTTP.start(uri.host, uri.port,
              :use_ssl => @api_url.start_with?("https://"),
              :ca_file => File.dirname(__FILE__) + '/cacert.pem',
              :read_timeout => 35,
              :open_timeout => 20,
            )
        end
                
        cls = get_request_class(method)        
        request = cls.new(uri)

        request['User-Agent'] = "Telerivet Ruby Client/#{@@client_version} Ruby/#{RUBY_VERSION} OS/#{RUBY_PLATFORM}"
        request.basic_auth(@api_key, "")

        if has_post_data
            request.set_content_type("application/json")           
            request.body = JSON.dump(params)            
        end
            
        @num_requests += 1

        response = @session.request(request)       
        
        res = JSON.parse(response.body)
        
        if res.has_key?("error")
            error = res['error']
            error_code = error['code']
            
            if error_code == 'invalid_param'
                raise InvalidParameterException, error['message'] #, error['code'], error['param'])
            elsif error_code == 'not_found'
                raise NotFoundException, error['message'] #, error['code']);
            else
                raise APIException, error['message'] #, error['code'])               
            end
        else
            return res    
        end
    end
    
    #
    # Retrieves the Telerivet project with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the project -- see <https://telerivet.com/dashboard/api>
    #       * Required
    #   
    # Returns:
    #     Telerivet::Project
    #
    def get_project_by_id(id)
        require_relative 'telerivet/project'
        Project.new(self, {'id' => id}, false)
    end
    
    #
    # Queries projects accessible to the current user account.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter projects by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name
    #         * Default: default
    #     
    #     - sort_dir
    #         * Sort the results in ascending or descending order
    #         * Allowed values: asc, desc
    #         * Default: asc
    #     
    #     - page_size (int)
    #         * Number of results returned per page (max 200)
    #         * Default: 50
    #     
    #     - offset (int)
    #         * Number of items to skip from beginning of result set
    #         * Default: 0
    #   
    # Returns:
    #     Telerivet::APICursor (of Telerivet::Project)
    #
    def query_projects(options = nil)
        require_relative 'telerivet/project'
        cursor(Project, '/projects', options)
    end
        
    def cursor(item_cls, path, options)
        APICursor.new(self, item_cls, path, options)
    end
    
    private
    
    def encode_params_rec(param_name, value, res)
        return if value == nil
        
        if value.kind_of?(Array)
            value.each_index { |i| encode_params_rec("#{param_name}[#{i}]", value[i], res) }            
        elsif value.kind_of?(Hash)
            value.each { |k,v| encode_params_rec("#{param_name}[#{k}]", v, res) }            
        elsif !!value == value
            res[param_name] = value ? 1 : 0
        else
            res[param_name] = value
        end
    end
            
    def get_url_params(params)
        res = {}
        if params != nil
            params.each { |key,value| encode_params_rec(key, value, res) }
        end
        return res    
    end
    
    def get_request_class(method)
        case method
        when 'GET' then return Net::HTTP::Get
        when 'POST' then return Net::HTTP::Post
        when 'DELETE' then return Net::HTTP::Delete
        when 'PUT' then return Net::HTTP::Put
        else return nil
        end
    end
    
end

class APIException < Exception
end

class NotFoundException < APIException
end

class InvalidParameterException < APIException
end

end