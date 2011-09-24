require 'socket'
require 'timeout'

class Roku
  attr_accessor :connected
  
  def initialize
    @socket = nil
    @connected=nil
  end
  
  def connect(ip,port)
    begin
      timeout(5) do
        @socket = TCPSocket.new(ip,port)
      end
      @connected = true
    rescue => e
      puts "Unable to connect to #{ip}:#{port}"
      puts e.message
      @connected = false
    end
  end
  
  def recieve
    "roku: ready"
  end
  
  def close
    @socket.close
  end
end