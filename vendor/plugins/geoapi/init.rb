
%w{rubygems rest_client httparty json crack/json uuidtools}.each { |x| require x }

# Patch HTTParty to debug 
HTTParty::Request.class_eval do
  class << self
    attr_accessor :debug
  end
  self.debug = true

  def perform_with_debug
    if self.class.debug
      puts "HTTParty making #{http_method::METHOD} request to:"
      puts uri
      puts "With Body: #{body}" 
    end
    
    retryable( :tries => 2 ) do
      perform_without_debug
    end
  end

  alias_method :perform_without_debug, :perform
  alias_method :perform, :perform_with_debug
end


# monkey patch HTTParty to use a configurable timeout
module HTTParty
  class Request
    private
      def http
        http = Net::HTTP.new(uri.host, uri.port, options[:http_proxyaddr], options[:http_proxyport])
        http.use_ssl = (uri.port == 443)
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.open_timeout = http.read_timeout = options[:timeout].to_i  if options[:timeout].to_i > 0
        puts "HTTParty timeout set to #{http.open_timeout}"
        http
      end
  end
end

def retryable(options = {}, &block)
  opts = { :tries => 1, :on => Exception }.merge(options)

  retry_exception, retries = opts[:on], opts[:tries]

  begin
    return yield
  rescue retry_exception
    retry if (retries -= 1) > 0
  end

  yield
end

class Array
  # Extract options from a set of arguments. Removes and returns the last element in the array if it's a hash, otherwise returns a blank hash.
  #
  #   def options(*args)
  #     args.extract_options!
  #   end
  #
  #   options(1, 2)           # => {}
  #   options(1, 2, :a => :b) # => {:a=>:b}
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

module GeoAPI
  API_VERSION = "v1"
  API_URL     = "http://api.geoapi.com/#{API_VERSION}/"

  class ArgumentError        < StandardError; end
  class BadRequest           < StandardError; end
  class NotFound             < StandardError; end
  class NotAcceptable        < StandardError; end
end


$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
require 'lib/geo_object' 
require 'lib/geometry' 
require 'lib/version'
require 'lib/entity'
require 'lib/entry'
require 'lib/view'
require 'lib/user_view'
require 'lib/query'
require 'lib/client'
require 'lib/neighborhood'
