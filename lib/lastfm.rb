require 'net/http'
require 'uri'
require 'digest/md5'
require

class LastFM
  @@api_base = "http://ws.audioscrobbler.com/2.0/"
  
  def initialize(apikey,secret)
    @apikey = apikey
    @secret = secret #not so secret anymore
    @sessionkey = nil
  end
  
  def domethod(method,*hash)
    args = "method=#{method}"
    params=hash[0]
    sendparams = {}
    params.each { |k,v| sendparams[k.to_s] = v.gsub(' ', '%20') }
    sendparams['method'] = method
    sendparams['api_key'] = @apikey
    url = URI.parse(@@api_base)
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data(sendparams)
    res = Net::HTTP.new(url.host,url.port).start { |http| http.request(req) }
    puts res.body
  end

  
  def auth(username,password,authstring)
    key = authstring.nil? ? auth_key(username,password) : authstring
    @sessionkey = nil
    params = {:username => username, :authToken => key}
    params[:api_sig] = methodSignature("auth.getMobileSession",params)
    domethod("auth.getMobileSession",params)
  end
  
  def methodSignature(method,params)
    params = params.dup
    params[:method] = method
    params[:api_key] = @apikey
    params = params.inject({}){ |res,(k,v)| res[k.to_s]=v; res }
    api_sig=""
    params.sort.each { |a| api_sig += "#{a[0]}#{a[1]}" }
    Digest::MD5.hexdigest(api_sig+@secret)
  end
  
  def auth_key(username,password)
    key = Digest::MD5.hexdigest(username.downcase + Digest::MD5.hexdigest(password))
    puts "You may want to put authstring = \"{key}\" in your config/config.rb instead of your password"
    key
  end
end