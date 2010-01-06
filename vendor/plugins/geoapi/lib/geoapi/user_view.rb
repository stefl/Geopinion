module GeoAPI
  class UserView < GeoAPI::View
    class << self
      @@path_prefix = GeoAPI::USERVIEW_PATH_PREFIX
    end
    
    def initialize attrs
      super attrs
    end
  end
end