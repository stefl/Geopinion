module GeoAPI
  class Neighborhood < GeoAPI::GeoObject
    
    attr_accessor :properties
    
    def self.entity_type
      "neighborhood"
    end
    
    def initialize attrs
      super(attrs)
      self.properties = attrs['properties']
      
    end
    
  end
end