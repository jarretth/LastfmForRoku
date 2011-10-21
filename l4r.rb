#!/usr/bin/env ruby
require './lib/rokusb/roku.rb'
require './lib/lastfm/lastfm.rb'
require './lib/l4rhelper.rb'
include L4RHelper


configfile = File.open('config/config.rb', "r")
config = {}
while !configfile.eof?
  line = configfile.readline.chomp.split("=").collect { |val| val.strip.gsub('"','') }
  config[line[0].to_sym] = line[1]
end
testconfig(config,:username)
abort "Must have a password or authstring in config/config.rb" if config[:password].nil? && config[:authstring].nil?
testconfig(config,:rokuaddress)
configfile.close


r = Roku.new.connect config[:rokuaddress]
l = LastFM.new('8f59d390f035d1151fce83e5a0d80e9a', '4c1998ae9519a3116bcac62b769907a8')
error = l.auth(config[:username],config[:password],config[:authstring])
raise "Last.fm returned an error #{error} while trying to authenticate" unless error.eql? config[:username]
puts "Error connecting to the Roku, continuing connect attempt" unless r.connected
begin
  currentsong = {}
  while 1
    sleeptime = 30
    a =  r.getCurrentSong
    if currentsong[:id] != a[:id]
      #scrobble on song change - this should the scrobble showing up alongside the now playing
      if !(currentsong[:id].nil?) && 
        validScrobbleTime(currentsong[:elapsedtime],currentsong[:totaltime])==0 
          puts "#{Time.now.ctime} - Error Scrobbling" unless l.scrobble(currentsong)
      end
      unless a[:id].nil?
        puts "#{Time.now.ctime} - Error updating Now Playing" unless l.updateNowPlaying(a)
      end
    end
    currentsong = a
    dif = validScrobbleTime(currentsong[:elapsedtime],currentsong[:totaltime])
    if dif==0 #this will scrobble on the next change
      sleeptime = [(currentsong[:totaltime] - currentsong[:elapsedtime])+1,30].min
    else #We need to still catch this before it scrobbles
      sleeptime = [dif,30].min
    end
    sleeptime = 1 if sleeptime <= 0
    sleep(sleeptime) 
  end
rescue RuntimeError
  puts "Disconnected! Retrying in 30 seconds"
  sleep(30)
  r = Roku.new.connect config[:rokuaddress]
  retry
end


