class BaseController < ApplicationController
  def site_index
    begin
      setup_post_reader
    
      @posts = @reader.response
    rescue 
      flash[:error] = "There was a problem loading the blog"
    end
  end
  
  def posts
    begin
      setup_post_reader
    
      @posts = @reader.response
    rescue 
      flash[:error] = "There was a problem loading the blog"
      redirect_to home_path
    end
  end
  
  def post
    begin
      setup_post_reader
    
      @post = @reader.response.first
    rescue 
      flash[:error] = "There was a problem loading the blog"
      redirect_to home_path
    end
  end
  
  def setup_post_reader
    #@account = Posterous::Client.new('stef+moseley@stef.io', 'moseleyftw!')
        
    @reader = Posterous::Reader.new("moseley", nil, 10) 
  end
end