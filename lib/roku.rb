require 'socket'

class Roku
  attr_accessor :connected
  
  def initialize
    @socket = nil
    @connected=nil
  end
  
  def connect(ip,port)
    @socket = TCPSocket.new(ip,port)
    @connected = true
  rescue => e
    puts "Unable to connect to #{ip}:#{port}"
    puts e.message
    @connected = false
  end
  
  def recieve
    "roku: ready"
  end
  
  def close
    @socket.close
  end
end