module ResourceController
  module Controller    
    def self.included(subclass)
      subclass.class_eval do
        include ResourceController::Helpers
        include ResourceController::Actions
        extend  ResourceController::Accessors
        extend  ResourceController::ClassMethods
        
        class_reader_writer :belongs_to, *NAME_ACCESSORS
        NAME_ACCESSORS.each { |accessor| send(accessor, controller_name.singularize.underscore) }

        ACTIONS.each do |action|
          class_scoping_reader action, FAILABLE_ACTIONS.include?(action) ? ResourceController::FailableActionOptions.new : ResourceController::ActionOptions.new
        end

        self.helper_method :object_url, :edit_object_url, :new_object_url, :collection_url, :object, :collection, 
                             :parent, :parent_type, :parent_object, :parent_model, :model_name, :model, :object_path, 
                             :edit_object_path, :new_object_path, :collection_path, :hash_for_collection_path, :hash_for_object_path, 
                                :hash_for_edit_object_path, :hash_for_new_object_path, :hash_for_collection_url, 
                                  :hash_for_object_url, :hash_for_edit_object_url, :hash_for_new_object_url, :parent?,
                                    :collection_url_options, :object_url_options, :new_object_url_options
                                
      end
      
      init_default_actions(subclass)
    end
        
    private
      def self.init_default_actions(klass)
        klass.class_eval do
          index.wants.html { render }
          index.wants.xml { render :xml => collection.to_xml }
          index.wants.json { render :json => collection.to_json }
          edit.wants.html
          new_action.wants.html

          show do
            wants.html { render }
            wants.xml { render :xml => object.to_xml }
            wants.json { render :json => object.to_json }

            failure.wants.html { redirect_to collection_url }
            failure.wants.xml { render :text => "Member object not found" }
            failure.wants.json { render :text => '{"error":"Member object not found"}' }
          end

          create do
            flash "Successfully created!"
            wants.html { redirect_to object_url }
            wants.xml { redirect_to object_url }
            wants.json { redirect_to object_url }
            
            failure.wants.html { redirect_to collection_url }
            failure.wants.xml { render :text => "Failed to create new object"}
            failure.wants.json { render :text => '{"error":"Failed to create new object"}' }
            
          end

          update do
            flash "Successfully updated!"
            wants.html { redirect_to object_url }
            wants.xml { redirect_to object_url }
            wants.json { redirect_to object_url }

            failure.wants.html { redirect_to object_url}
            failure.wants.xml { render :text => "Failed to update object"}
            failure.wants.json { render :text => '{"error":"Failed to update object"}' }
          end

          destroy do
            flash "Successfully removed!"
            wants.html { redirect_to collection_url }
            wants.xml { redirect_to collection_url }
            
            failure.wants.html { redirect_to collection_url}
            failure.wants.xml { render :text => "Failed to destroy object"}
            failure.wants.json { render :text => '{"error":"Failed to destroy object"}' }
          end
          
          class << self
            def singleton?
              false
            end
          end
        end
      end
  end
end
