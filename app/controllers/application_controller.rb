# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :lat_lng_session
  
  
  def lat_lng_session
    
    if session[:lat].blank? || 1==1
      session[:lat] = -1.888213
      session[:lng] = 52.446506
      session[:scale] = 1
    end
  end
end
