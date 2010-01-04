class EntitiesController < ResourceController::Base
      
    include ActionView::Helpers::PrototypeHelper
    include ActionView::Helpers::JavaScriptHelper
    
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
      
      @map.center = GoogleMap::Point.new(session[:lat], session[:lng])
      @map.zoom = 14
      
      unless @entities.blank?
        @entities.each do |entity|
          @map.markers << GoogleMap::Marker.new(  :map => @map, :lat => entity.latitude, :lng => entity.longitude, :html => "<a href='/entities/#{entity.id}'>#{entity.name}</a>") unless entity.latitude.blank? || entity.longitude.blank? 
        end
      end
    end


    index.wants.json{
      render :json=>@entities.to_json
    }
    
    new_action.wants.html{
      setup_map
      
      @map.center = GoogleMap::Point.new(session[:lng], session[:lat])
      @map.double_click_zoom = false
      @map.inject_on_load = 'GEvent.addListener(google_map,"dblclick", function(overlay, latlng) {     
        if (latlng) { 
          var myHtml = "My idea is for here: " + latlng.lat() + "," + latlng.lng();
          
          $("#entity_lat").val(latlng.lat());
          $("#entity_lng").val(latlng.lng());
          
          google_map.openInfoWindow(latlng, myHtml);
        }
      });'
      
      @map.zoom = 16
      
    }
    
    def locate
      session[:lat] = params[:lat].to_f
      session[:lng] = params[:lng].to_f
      
      render :text=>true
    end
    
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
      
    end
    
    show.wants.html{
      response.headers['Cache-Control'] = 'public, max-age=300'
      
      setup_map
      
      @entities = Entity.search({:lat=>@entity.latitude, :lng=>@entity.longitude, :type=>"user-entity"})
      
      @map.center = GoogleMap::Point.new(@entity.latitude, @entity.longitude)
      
      @map.markers << GoogleMap::Marker.new(  :map => @map, 
                                              :lat => @entity.latitude, 
                                              :lng => @entity.longitude,
                                              :html => @entity.name)
                                              
      @map.zoom = 16
      
      unless @entities.blank?
        @entities.each do |entity|
          @map.markers << GoogleMap::Marker.new(  :map => @map, :lat => entity.latitude, :lng => entity.longitude, :html => "<a href='/entities/#{entity.id}'>#{entity.name}</a>") unless entity.latitude.blank? || entity.longitude.blank? 
        end
      end
                                                 
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
