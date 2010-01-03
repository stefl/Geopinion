class EntriesController < ResourceController::Base
  
  index.wants.xml{
      @entities = parent_object.entries
      render :xml=>@entities
  }

  index.wants.html{
    @entities = parent_object.entries
  }

  index.wants.json{
    @entities = parent_object.entries
    render :json=>@entries.to_json
  }
  
  
  show.wants.json{render :json=>@entity.to_json}

  show.wants.xml{render :xml=>@entity.to_xml}
  
  private
    def object
      @object ||= Entry.find_by_id(param)
    end
    
    def parent_object
      @parent_object ||= Entity.find_by_id(param)
    end
  
end
