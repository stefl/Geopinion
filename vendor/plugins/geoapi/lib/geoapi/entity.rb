module GeoAPI
  class Entity < GeoAPI::GeoObject
    
    attr_accessor  :guid, :id, :name, :entity_type, :geom, :url, :views, :userviews, :raw_json, :errors, :shorturl, :raw_json
        

    alias_method :geometry, :geom

    def latitude
      @latitude ||= geometry.latitude unless geometry.blank?
    end
    
    def longitude
      @longitude ||= geometry.longitude unless geometry.blank?
    end
    
    alias_method :lat, :latitude 
    alias_method :lon, :longitude
    alias_method :lng, :longitude
    
    # Class methods
    
    
    def self.create(params)
      puts "GEOAPI::Entity.create #{params.to_json}"
      #required: name, geom
      #optional: pass id and it will create a new guid for you as user-<apikey>-<id>
      
      raise ArgumentError, "A name is required (pass :name in parameters)" unless params.has_key?(:name)
      raise ArgumentError, "A geometry is required (pass :geom in parameters)" unless params.has_key?(:geom)
      
      api_key = self.api_key_from_parameters(params)
      
      raise ArgumentError, "An API Key is required" if api_key.blank?
      
      id = params[:id] || UUIDTools::UUID.timestamp_create().to_s
      
      post_url = "/e" 
      post_url = "/e/user-#{api_key}-#{id}?apikey=#{api_key}" unless id.blank?
      post_url = "/e/#{params[:guid]}?apikey=#{api_key}" unless params[:guid].blank?

      puts post_url
      
      params.delete(:id) if params.has_key?(:id)
      params.delete(:guid) if params.has_key?(:guid)
      
      begin
        results = Entity.post(post_url, {:body=> params.to_json}) 
      rescue
        raise BadRequest, "There was a problem communicating with the API"
      end
      
      raise BadRequest, results['error'] unless results['error'].blank?
      
      #todo the result does not contain the guid, so merge it back in. Possible point of failure here?
      
      guid = results['query']['params']['guid']
      Entity.new(results['result'].merge({'guid'=>guid, 'id'=>GeoAPI::Client.id_from_guid(guid,api_key)}))
    end
    
    def self.destroy(params)
      
      puts "GEOAPI::Entity.destroy #{params.to_json}"
      
      raise ArgumentError, "An id or guid is required (pass :id or :guid in parameters)"  unless params.has_key?(:id) || params.has_key?(:guid)      
      
      raise ArgumentError, "An API Key is required" if api_key.blank?
      
      begin
        unless params[:guid].blank?
          delete("/e/#{params[:guid]}?apikey=#{api_key}") 
        else
          delete("/e/user-#{api_key}-#{params[:id]}?apikey=#{api_key}") unless params[:id].blank?
        end
      
      rescue
        raise BadRequest, "There was a problem communicating with the API"
      end
    end
    
    def self.create_at_lat_lng(*args)
      
      params = args.extract_options!
      params = params == {} ? nil : params
      
      puts "GEOAPI::Entity.create_at_lat_lng #{params.to_json}"
      
      raise ArgumentError, ":lat must be sent as a parameter" unless params.has_key?(:lat)
      raise ArgumentError, ":lng must be sent as a parameter" unless params.has_key?(:lng)
      puts "test API key #{api_key}"
      raise ArgumentError, "An API Key is required" if api_key.blank?
      
      p = GeoAPI::Point.new(:lng => params[:lng], :lat => params[:lat])
      
      params.delete(:lat)
      params.delete(:lng)

      self.create(params.merge({:geom=>p}))
    end
    
    def self.find(*args)
      
      puts "GEOAPI::Entity.find #{args.to_s}"
      
      raise ArgumentError, "First argument must be symbol (:all or :get)" unless args.first.kind_of?(Symbol)
      
      params = args.extract_options!
      params = params == {} ? nil : params
      
      api_key = self.api_key_from_parameters(params)
      
      raise ArgumentError, "An API Key is required" if api_key.blank?
      
      case args.first
        
        when :all
          results = []
        else
          results = nil
          
          raise ArgumentError, "Arguments should include a :guid or :id" if params[:guid].blank? && params[:id].blank?
        
          params[:guid] = "user-#{api_key}-#{the_id}" unless params[:id].blank?
        
          response = get("/e/#{params[:guid]}?apikey=#{api_key}")
          
          begin
            
          rescue
            raise BadRequest, "There was a problem communicating with the API"
          end
        
          results = Entity.new(response['result'].merge({'guid'=>params[:guid]})) unless response['result'].blank? #the api doesn't return a guid in json?!
      end
            
      results
      
    end
    
    def self.find_by_id(the_id, options={})
      puts "GEOAPI::Entity.find_by_id #{the_id}"
      
      api_key = self.api_key_from_parameters(options)
      
      raise ArgumentError, "An API Key is required" if api_key.blank?
      
      self.find(:get, :guid=>"user-#{api_key}-#{the_id}")
    end
    
    def self.find_by_guid(the_guid, options={})
      puts "GEOAPI::Entity.find_by_guid #{the_guid}"
      
      api_key = self.api_key_from_parameters(options)
      
      raise ArgumentError, "An API Key is required" if api_key.blank?
      
      self.find(:get, :guid=>the_guid)
    end
    
    def self.search(conditions, options={})
      puts "GEOAPI::Entity.search #{conditions.to_s}"
      
      raise ArgumentError, ":lat and :lng are required for search" unless conditions.has_key?(:lat) && conditions.has_key?(:lng)
      
      api_key = self.api_key_from_parameters(options)
      
      raise ArgumentError, "An API Key is required" if api_key.blank?
      
      # Accepts all conditions from the API and passes them through - http://docs.geoapi.com/Simple-Search
      
      conditions.merge!({:lat=>conditions[:lat],:lon=>conditions[:lng],:apikey=>api_key})
      conditions.delete(:lng)
      
      
      begin
        response = get("/search", {:timeout=>60, :query=>conditions})
        
      rescue
        raise BadRequest, "There was a problem communicating with the API"
      end
      results = []
      unless response.blank? || response['result'].blank?
        response['result'].each do |result|
          results << Entity.new(result)
        end
        results.reverse!
      end
    end
    
    # Instance methods
    def initialize(attrs)
      super attrs
      self.setup(attrs) unless attrs.blank?
    end
    
    def setup(attrs)
      puts "Setup Entity with attributes: #{attrs.to_json}"
      api_key = @api_key
      api_key ||= self.api_key_from_parameters(params)
      
      self.guid = attrs['guid'] if attrs.has_key?('guid')
      self.guid = "user-#{@api_key}-#{attrs['id']}" if attrs.has_key?('id')
      puts "GEOAPI::Entity.setup #{self.guid}"
      self.id = attrs['id'] if attrs.has_key?('id')
      self.id = GeoAPI::Client.id_from_guid(self.guid,api_key) if self.id.blank?
      self.errors = attrs['error']
      self.name = attrs['name']
      self.name ||= attrs['meta']['name'] unless attrs['meta'].blank?
      self.entity_type = attrs['type']
      self.shorturl = attrs['shorturl']
            
      self.geom = GeoAPI::Geometry.from_hash(attrs['geom']) unless attrs['geom'].blank?
      self.geom ||= GeoAPI::Geometry.from_hash(attrs['meta']['geom']) unless attrs['meta'].blank?
      
      
      self.views = []
      unless attrs['views'].blank?
        if attrs['views'].size > 0
          attrs['views'].each do |view|
            self.views << GeoAPI::View.new({'name'=>view, 'guid'=>self.guid})
            
            # Dynamically create methods like twitter_view
            
             (class <<self; self; end).send :define_method, :"#{view}_view" do
                find_view("#{view}")
              end

              (class <<self; self; end).send :define_method, :"#{view}_view_entries" do
                find_view_entries("#{view}")
              end
          end   
        end
      end
      
      self.userviews = []
      unless attrs['userviews'].blank?
        if attrs['userviews'].size > 0
          attrs['userviews'].each do |view|
            self.userviews << GeoAPI::UserView.new({'name'=>view, 'guid'=>self.guid})
            
            # Dynamically create methods like myapp_userview
            class << self
              define_method "#{view}_userview" do
                find_view("#{view}")
              end
            
              define_method :"#{view}_entries" do
                #todo needs caching here
                find_view("#{view}").entries
              end
            end
            
          end
        end
      end
      
      self
    
    end
      
    def type #type is a reserved word
      self.entity_type 
    end
    
    def update
      puts "GEOAPI::Entity.update #{self.guid}"
      
      raise ArgumentError, "An API Key is required" if api_key.blank?
      
      self.setup(post("/e/#{guid}?apikey=#{api_key}", {:body=>self.to_json}))
    end
    
    def load
      puts "GEOAPI::Entity.load #{self.guid}"
      
      raise ArgumentError, "An API Key is required" if api_key.blank?
      
      raise ArgumentError, "Properties should include a .guid or .id" if self.guid.blank? && self.id.blank?
      
      the_guid = self.guid
      the_guid ||= "user-#{api_key}-#{self.id}"
      
      begin
        response = self.class.get("/e/#{the_guid}?apikey=#{api_key}")
      rescue
        raise BadRequest, "There was a problem communicating with the API"
      end
            
      self.setup(response['result'].merge({'guid'=>self.guid })) 
      
      self
    end
    
    def delete
      puts "GEOAPI::Entity.delete #{self.guid}"
      
      raise ArgumentError, "An API Key is required" if api_key.blank?
      
      raise ArgumentError, "Object has no :guid" if self.guid.blank?
      begin
        Entity.destroy(:guid=>self.guid)
      rescue
        raise BadRequest, "There was a problem communicating with the API"
      end
      
    end
    
    def destroy
      self.delete
    end
    
    def save
      update
    end
    
    def to_s
      self.name
    end
    
    def to_json options=nil
      {:name=>name, :guid=>guid, :type=>entity_type, :geom=>geom, :views=>views, :userviews=>userviews, :shorturl=>shorturl}.to_json
    end
    
    # Common facility methods
    
    def find_view view_name
      views.each do |view|
        return view if view.name == view_name
      end
    end
    
    def find_view_entries view_name
      find_view(view_name).load.entries
    end
    
  end
end