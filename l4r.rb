require './lib/roku.rb'

r = Roku.new.connect '192.168.2.126'
begin
  currentsong = 0
  sent = false
  sleeptime = 30
  while 1
    a = r.getCurrentSong
    if a[:id].nil? == false
      puts "we have a song((#{a[:id]})#{a[:artist]} - #{a[:title]})"
      #if it's a new song, send nowPlaying to last.fm, mark the song
      if currentsong != a[:id]
        sent = false
        currentsong = a[:id]
        sleeptime = 30
        puts "send initial update to last.fm"
      #if it's the same song, but we haven't scrobbled it yet
      elsif sent == false
        #check if it is half way though, or 4 minutes through
        if a[:elapsedtime] >= (a[:totaltime]/2) || a[:elapsedtime] >= 240
          #scrobble
          puts "send final to last.fm"
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
      puts "we have no song"
      currentsong = 0
      sleeptime = 30
    end
    sleep(sleeptime)
  end
rescue RuntimeError
  puts "Disconnected! Retrying in 30 seconds"
  sleep(30)
  r = Roku.new.connect '192.168.2.126'
  retry
end