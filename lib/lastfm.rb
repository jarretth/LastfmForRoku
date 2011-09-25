require 'net/http'
require 'uri'

class LastFM
  @@api_base = "http://ws.audioscrobbler.com/2.0/?"
  def initialize(apikey,secret)
    @apikey = apikey
    @secret = secret
  end
  
  def domethod(method,*hash)
    args = "method=#{method}"
    unless hash[0].nil?
      if hash[0].instance_of? Hash
        hash[0].each { |k,v| args += "&#{k.to_s}=#{v}"}
      elsif 
        args += "&"
        args += hash.join('&')
      end
    end
    args += "&api_key=#{@apikey}"
    url = @@api_base + args
    puts url
  end
end