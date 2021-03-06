require 'socket'
require 'timeout'
#sketch
#rect 1 1 270 15
#color 0
#rect 10 3 250 11
#text 25 6 "Last.fm for Roku (c) Jarrett Hawrylak"
class Roku
  attr_accessor :connected
  
  def initialize
    @socket = nil
    @connected=nil
  end
  
  def connect(ip)
    begin
      timeout(1) { @socket = TCPSocket.new(ip,4444) }
      drawCopyright
      #sleep(5)
      @socket.close
      @socket = TCPSocket.new(ip,5555)
      @connected=true
    rescue Timeout::Error
      @connected = false
    rescue => e
      @connected = false
    end
    return nil if @connected==false
    sleep(0.3)
    (@connected=false||@socket=nil) unless @socket.recv(1000) == "roku: ready\r\n"
    self
  end
  
  def getCurrentSong
    return nil if @socket.nil?
    song = {}
    begin
      timeout(5) {
        @socket.send("GetCurrentSongInfo\r\n",0)
        sleep(0.2)
        d=@socket.recv(1000).chomp
        return {} if d.nil? || (d =~ /.*GenericError.*/) || !(d =~ /.*OK.*/)
        d = d.split("\r\n").collect() do
          |x| y=x.split(': ');
          if !y[1].nil?
            {y[1].to_sym=>y[2]}
          else
            nil
          end
        end
        song = d.inject({}) do |rem,obj| 
          if obj.nil?
            rem
          else
            rem.merge obj
          end
        end
        @socket.send("GetElapsedTime\r\n",0)
        sleep(0.2)
        a = (@socket.recv(1000).chomp.split(": "))[1]
        if (a.nil? || a.eql?("GenericError"))
          return song
        end
        a = a.split(":").collect {|e| e.to_i}
        song[:elapsedtime] = (a[0]||0)*3600+(a[1]||0)*60+(a[2]||0)
        @socket.send("GetTotalTime\r\n",0)
        sleep(0.2)
        a = (@socket.recv(1000).chomp.split(": "))[1]
        if(a.nil? || a.eql?("GenericError"))
          return song
        end
        a = a.split(":").collect {|e| e.to_i}
        song[:totaltime] = (a[0]||0)*3600+(a[1]||0)*60+(a[2]||0)
      }
    rescue Timeout::Error => e
      @connected = false
      @socket.close
      @socket = nil
      raise "Unexpected disconnection"
    end
    #p song
    song   
  end
  
  def drawCopyright
    return nil if @socket.nil?
    begin
      timeout(5) {
        @socket.send("sketch\r\n",0)
        @socket.send("rect 1 1 270 15\r\n",0)
        @socket.send("color 0\r\n",0)
        @socket.send("rect 10 3 250 11\r\n",0)
        @socket.send("text 25 6 \"Last.fm for Roku (c) Jarrett Hawrylak\"\r\n",0)
      }
    rescue Timeout::Error
      @connected=false
      @socket.close
      @socket = nil
      raise "Unexpected disconnection"
    end
  end
  
  def close
    @socket.send("exit",0) unless @socket.nil?
    @socket.close unless @socket.nil?
    @connected = false
  end
end