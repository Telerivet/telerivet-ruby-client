module Telerivet

#
# An easy-to-use interface for interacting with API methods that return collections of objects
# that may be split into multiple pages of results.
# 
# Using the APICursor, you can easily iterate over query results without
# having to manually fetch each page of results.
#
class APICursor

    include Enumerable

    def initialize(api, item_cls, path, params = nil)
        params ||= {}

        if params.has_key?('count')
            raise Exception, "Cannot construct APICursor with 'count' parameter. Call the count() method instead."
        end

        @api = api
        @item_cls = item_cls
        @path = path
        @params = params

        @count = -1
        @pos = nil
        @data = nil
        @truncated = nil
        @next_marker = nil
        @limit = nil
        @offset = 0
    end

    def each()
        loop do
            item = self.next()
            return if item == nil
            yield item
        end
    end

    #
    # Limits the maximum number of entities fetched by this query.
    # 
    # By default, iterating over the cursor will automatically fetch
    # additional result pages as necessary. To prevent fetching more objects than you need, call
    # this method to set the maximum number of objects retrieved from the API.
    # 
    # Arguments:
    #   - limit (int)
    #       * The maximum number of entities to fetch from the server (may require multiple API
    #           calls if greater than 200)
    #       * Required
    #   
    # Returns:
    #     the current APICursor object
    #
    def limit(_limit)
        @limit = _limit
        self
    end

    #
    # Returns the total count of entities matching the current query, without actually fetching
    # the entities themselves.
    # 
    # This is much more efficient than all() if you only need the count,
    # as it only results in one API call, regardless of the number of entities matched by the
    # query.
    # 
    # Returns:
    #     int
    #
    def count()
        if @count == -1
            params = @params.clone
            params['count'] = 1

            res = @api.do_request("GET", @path, params)
            @count = res['count'].to_i
        end
        @count
    end

    def all()
        to_a
    end

    #
    # Returns true if there are any more entities in the result set, false otherwise
    # 
    # Returns:
    #     bool
    #
    def has_next?()
        return false if @limit != nil && @offset >= @limit

        load_next_page() if @data == nil

        return true if @pos < @data.length

        return false if !@truncated

        load_next_page()

        @pos < @data.length
    end

    #
    # Returns the next entity in the result set.
    # 
    # Returns:
    #     Telerivet::Entity
    #
    def next()
        if @limit != nil && @offset >= @limit
            return nil
        end

        if @data == nil || (@pos >= @data.length && @truncated)
            load_next_page()
        end

        if @pos < @data.length
            item_data = @data[@pos]
            @pos += 1
            @offset += 1
            cls = @item_cls
            if cls
                return cls.new(@api, item_data, true)
            else
                return item_data
            end
        else
            return nil
        end
    end

    def load_next_page()
        request_params = @params.clone

        if @next_marker != nil
            request_params['marker'] = @next_marker
        end

        if @limit != nil && !request_params.has_key?("page_size")
            request_params['page_size'] = [@limit, 200].min
        end

        response = @api.do_request("GET", @path, request_params)

        @data = response['data']
        @truncated = response['truncated']
        @next_marker = response['next_marker']
        @pos = 0
    end
end

end