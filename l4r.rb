require './lib/roku.rb'

r = Roku.new.connect '192.168.2.126'
begin
  currentsong = 0
  elapsed = 0
  sent = false
  sleeptime = 30
  while 1
    a = r.getCurrentSong
    if a[:id].nil? == false
      puts "we have a song((#{a[:id]})#{a[:artist]} - #{a[:title]})"
      if currentsong != a[:id]
        sent = false
        currentsong = a[:id]
        sleeptime = 30
        puts "send initial update to last.fm"
      elsif sent == false
        if elapsed >= 30
          puts "send final to last.fm"
          sleeptime = (a[:totaltime]-a[:elapsedtime] > 30) ? 30 : (a[:totaltime]-a[:elapsedtime])+1
          sent = true
        else
          sleeptime = 40-elapsed
        end
      end
      elapsed=a[:elapsedtime]
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