#require 'rubygems'
require 'jimson'

class RpcClient
   include HTTParty

  #private :client
  #def initialize(url, port)
  #  client = Jimson::Client.new("#{url}:#{port}")
  #  puts "Created client: #{client.to_s}"
  #end
  
  def initialize(server)
    @xbmc = server
  end

  def set_xbmc_config(location="default")
    #if (!@xbmc.has_key?(location) || !@xbmc[location].has_key?("host") || !@xbmc[location]["host"] == "")
    #  puts "[#{@appname}] No host configured for #{location}."
    #  return false
    #end

    self.class.base_uri "http://#{@xbmc}"
    #self.class.basic_auth @xbmc[location]["username"], @xbmc[location]["password"]

    return true
  end
l

  # API interaction: Invokes the given method with given params, parses the JSON response body, maps it to
  # a HashWithIndifferentAccess and returns the :result subcollection
  def xbmc(method, params={})
    JSON.parse(invoke_json_method(method, params).body).with_indifferent_access[:result]
  end
    
  # Raw API interaction: Invoke the given JSON RPC Api call and return the raw response (which is an instance of
  # HTTParty::Response)
  def invoke_json_method(method, params={})
    response = self.class.post('/jsonrpc', :body => {"jsonrpc" => "2.0", "params" => params, "id" => "1", "method" => method}.to_json,:headers => { 'Content-Type' => 'application/json' } )    
raise XBMCLibrary::UnauthorizedError, "Could not authorize with XBMC. Did you set up the correct user name and password ?" if response.response.class == Net::HTTPUnauthorized
    response
      
    # Capture connection errors and send them out with a custom message
    rescue Errno::ECONNREFUSED, SocketError, HTTParty::UnsupportedURIScheme => err
    raise err.class, err.message + ". Did you configure the url and port for XBMC properly using Xbmc.base_uri 'http://localhost:1234'?"
  end
end
