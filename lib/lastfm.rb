require 'net/http'
require 'uri'
require 'digest/md5'

class LastFM
  @@api_base = "http://ws.audioscrobbler.com/2.0/?"
  def initialize(apikey,secret)
    @apikey = apikey
    @secret = secret #not so secret anymore
  end
  
  def auth_key(username,password)
    puts Digest::MD5.hexdigest(username + Digest::MD5.hexdigest(password))
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