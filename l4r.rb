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
begin
  currentsong = 0
  sent = false
  sleeptime = 30
  while 1
    a =  r.getCurrentSong
    if a.nil? == false && a[:id].nil? == false
      #puts "we have a song((#{a[:id]})#{a[:artist]} - #{a[:title]})"
      #if it's a new song, send nowPlaying to last.fm, mark the song
      if currentsong != a[:id]
        sent = false
        currentsong = a[:id]
        sleeptime = 30
        puts "error updating Now Playing" unless l.updateNowPlaying(a)
      #if it's the same song, but we haven't scrobbled it yet
      elsif sent == false
        #check if it is half way though, or 4 minutes through
        if a[:elapsedtime] >= (a[:totaltime]/2) || a[:elapsedtime] >= 240
          puts "error scrobbling" unless l.scrobble(a)
          #sleep until the end of the song or the next 30 seconds
          sleeptime = (a[:totaltime]-a[:elapsedtime] > 30) ? 30 : (a[:totaltime]-a[:elapsedtime])+1
          sent = true
        else
          #sleep for the time until half of the song or 30s, whichever comes first
          dif = (a[:totaltime]/2 - a[:elapsedtime])+1
          sleeptime = (dif <= 0) ? 30 : ((dif>30) ? 30 : dif) 
        end
      #it the same song we've already sent
      else
        #sleep until min(30s,end time)
        sleeptime = (a[:totaltime]-a[:elapsedtime] > 30) ? 30 : (a[:totaltime]-a[:elapsedtime])+1
      end
    else
      #puts "we have no song"
      currentsong = 0
      sleeptime = 30
    end
    sleep(sleeptime)
  end
rescue RuntimeError
  puts "Disconnected! Retrying in 30 seconds"
  sleep(30)
  r = Roku.new.connect config[:rokuaddress]
  retry
end
