require 'net/http'
require 'uri'
require 'open-uri'
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
    args.gsub!(' ', '%20')
    puts url = @@api_base + args
    open(url,'User-Agent'=>'Lastfm4Roku') { |f|
      while !f.eof?
        puts f.readline.chomp
      end
      }
  end
end