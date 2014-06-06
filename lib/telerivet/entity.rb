module Telerivet

class Entity    
    
    def initialize(api, data, is_loaded = true)
        @api = api
        @vars = nil
        @dirty = {}
        @data = {}
        set_data(data)
        @is_loaded = is_loaded        
    end
    
    def set_data(data)
        @data = data
        
        if data.has_key?('vars')
            @vars = CustomVars.new(data['vars'])
        else
            @vars = CustomVars.new({})
        end
    end
    
    def load_data()    
        if !@is_loaded
            @is_loaded = true
            set_data(@api.do_request('GET', get_base_api_path()))
        end
    end
        
    def vars
        @vars
    end
        
    def get(name)        
        if @data.has_key?(name)
            return @data[name]
        elsif @is_loaded
            return nil
        end

        load_data()
        
        return @data[name]
    end
    
    def set(name, value)
        if !@is_loaded
            loadData()
        end
        
        @data[name] = value
        @dirty[name] = value
    end
    
    def save()    
        dirty_props = @dirty

        if @vars != nil
            dirty_vars = @vars.get_dirty_variables()
            @dirty['vars'] = dirty_vars if dirty_vars.length() > 0
        end
            
        @api.do_request('POST', get_base_api_path(), @dirty)
        @dirty = {}
        
        @vars.clear_dirty_variables() if @vars != nil
    end
    
    def to_s()
        res = self.class.name
        
        if not @is_loaded
            res += " (not loaded)"
        end

        res += " JSON: " + JSON.dump(@data)
        
        return res
    end
    
    def get_base_api_path()
        abstract
    end
end

class CustomVars
    def initialize(vars)
        @vars = vars
        @dirty = {}
    end
    
    def all()
        @vars
    end
    
    def get_dirty_variables()
        @dirty
    end
    
    def clear_dirty_variables()
        @dirty = {}
    end

    def get(name)
        @vars[name]
    end
    
    def set(name, value)
        @vars[name] = value
        @dirty[name] = value
    end
    
    def method_missing(m, *args)
        name = m.to_s
        if name.end_with?('=')
            set(name.chop, args[0])
        else
            get(name)
        end
    end  
end

end