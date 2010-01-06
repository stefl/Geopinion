module GeoAPI
  class Entry < GeoAPI::GeoObject
    
    attr_accessor :properties
    
    def initialize attrs
      super(attrs)
      self.properties = attrs['properties']
      
    end
  end
end