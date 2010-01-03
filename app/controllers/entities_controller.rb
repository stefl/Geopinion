class EntitiesController < ResourceController::Base
      
    index.before do
      begin
        @entities = Entity.search({:lat=>session[:lat], :lng=>session[:lng], :type=>"user-entity"})
      rescue Timeout::Error
        puts "Timeout::Error"
        flash[:error] = "Sorry - the service was slow to respond, try reloading the page"
        @entities = []
      end
    end
    
    index.wants.xml{
     
      render :xml=>@entities
    }
    
    index.wants.html do
      
      setup_map
      
      @map.center = GoogleMap::Point.new(session[:lng], session[:lat])
      
      
      unless @entities.blank?
        @entities.each do |entity|
          @map.markers << GoogleMap::Marker.new(  :map => @map, :lat => entity.latitude, :lng => entity.longitude, :html => entity.name) unless entity.latitude.blank? || entity.longitude.blank? 
        end
      end
    end


    index.wants.json{
      render :json=>@entities.to_json
    }
    
    def create
      @entity = Entity.create_at_lat_lng(params[:entity])
      
      respond_to do |wants|
        wants.html do
          unless @entity.blank?
            flash[:error] = "The entity has been created"
            redirect_to(entity_path(@entity.id))
          else
            flash[:error] = "It was not possible to create that Entity - please try again."
            redirect_to(new_entity_path)
          end
        end
      end
    end
    
    def setup_map
      @map = GoogleMap::Map.new
      @map.controls = [ :large, :scale, :type ]
      @map.double_click_zoom = true
      @map.zoom = 14
    end
    
    show.wants.html{
      response.headers['Cache-Control'] = 'public, max-age=300'
      
      setup_map
      
      @map.center = GoogleMap::Point.new(@entity.latitude, @entity.longitude)
      
      @map.markers << GoogleMap::Marker.new(  :map => @map, 
                                              :lat => @entity.latitude, 
                                              :lng => @entity.longitude,
                                              :html => @entity.name)
                                                 
      # Alternative method for polylines:
      
      # plot points for polyline
      #        vertices = []
      #        object.gpxroute.gpxtrackpoints.each do |p|
      #          vertices << GoogleMap::Point.new(p.lat, p.lon)
      #        end
      #
      #      # plot polyline
      #    @map.overlays << GoogleMap::Polyline.new(  :map => @map, 
      #                          :color=>'#FF0000', 
      #                          :weight=>'2', 
      #                          :opacity=>'.5', 
      #                         :vertices=>vertices
      #                          )
      
      
      
    }
    
    show.wants.json{render :json=>@entity.to_json}

    show.wants.xml{render :xml=>@entity.to_xml}
    
    private
      def object
        @object ||= Entity.find_by_id(param)
      end
  
end
