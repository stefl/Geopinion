module GeoAPI
  class View < GeoAPI::GeoObject
    
    attr_accessor :name, :guid, :view_type, :id, :entries
    
    class << self
      attr_accessor :path_prefix
    end
    
    GeoAPI::VIEW_PATH_PREFIX = "view"
    GeoAPI::USERVIEW_PATH_PREFIX = "userview"

    
    # Class methods
    
    def self.path_prefix
      case self.to_s
        when "GeoAPI::View" then VIEW_PATH_PREFIX
          
        when "GeoAPI::UserView" then USERVIEW_PATH_PREFIX
      end
    end
    
    def self.find(*args)
      
      #raise ArgumentError, "First argument must be symbol (:all or :get)" unless args.first.kind_of?(Symbol)
      
      params = args.extract_options!
      params = params == {} ? nil : params
      
      results = nil
      params[:guid] = "user-#{GeoAPI::API_KEY}-#{params[:id]}" unless params[:id].blank?
      raise ArgumentError, "Arguments should include a entity :guid or an :id" if params[:guid].blank? && params[:id].blank?
      raise ArgumentError, "Arguments should include a view :name" if params[:name].blank?
      
      begin
        debugger
        
        response = get("/e/#{params[:guid]}/#{self.class.path_prefix}/#{params[:name]}")
      rescue
        raise BadRequest, "There was a problem communicating with the API"
      end
      
      entries = {'entries' => response['result']} # There are no entries in this view
    
      results = View.new(entries.merge({'guid'=>params[:guid], 'name'=>params[:name]})) unless response['result'].blank? #the api doesn't return a guid in json?!

      results
    end
    
    
    # Instance methods
    def initialize attrs
      setup(attrs)
    end
    
    def setup attrs
      self.name = attrs['name']
      self.guid = attrs['guid']
      self.view_type = attrs['type']
      
      self.entries = []
      unless attrs['entries'].blank?
        if attrs['entries'].size > 0
          attrs['entries'].each do |entry|
            self.entries << GeoAPI::Entry.new({'properties'=>entry})  
          end
          self.entries.reverse!
        end
      end
    end
    
    
    def load
      raise ArgumentError, "Properties should include a .guid or .id" if self.guid.blank? && self.id.blank?
      raise ArgumentError, "Properties should include a .name" if self.name.blank?
      
      the_guid = self.guid
      
      the_guid ||= "user-#{GeoAPI::API_KEY}-#{self.id}"
      
      begin
        response = self.class.get("/e/#{the_guid}/#{self.class.path_prefix}/#{self.name}")
      rescue
        raise BadRequest, "There was a problem communicating with the API"
      end
    
      entries = {'entries' => response['result']} # There are no entries in this view
        
      self.setup(entries.merge({'guid'=>self.guid, 'name'=>self.name })) 
      
      self
    end
    
    def to_json options=nil
      {:name=>name, :guid=>guid, :type=>view_type}.to_json
    end
  end

end
