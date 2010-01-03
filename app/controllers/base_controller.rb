class BaseController < ApplicationController
  def site_index
    setup_post_reader
    
    @posts = @reader.response
    
  end
  
  def posts
    setup_post_reader
    
    @posts = @reader.response
    render "posts/index"
  end
  
  def post
    setup_post_reader
    
    @post = @reader.response.first
    render "posts/show"
  end
  
  def setup_post_reader
    #@account = Posterous::Client.new('stef+moseley@stef.io', 'moseleyftw!')
        
    @reader = Posterous::Reader.new("moseley", nil, 10)
  end
end