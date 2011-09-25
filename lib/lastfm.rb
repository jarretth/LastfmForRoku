require 'net/http'
require 'uri'

class LastFM
  
  def initialize(apikey,secret)
    @apikey = apikey
    @secret = secret
  end
end