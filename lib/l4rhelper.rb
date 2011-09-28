module L4RHelper
  def testconfig(hash,key)
    abort("Must have #{key.to_s} in config/config.rb in the form of #{key.to_s} = \"#{key.to_s}\"") if hash[key].nil?
  end
  
  def validScrobbleTime(elapsed,total)
    return 30 if (elapsed.nil? || total.nil?)
    #Half of the total time or 4 minutes, given the total time is greater than 30s
    #returns 0 if valid scrobble, time until a valid scrobble otherwise
    retval = 0
    if total > 30
      if ((total/2 <= elapsed) || (elapsed >= 240))
        retval = 0
      else
        retval = (total/2) - elapsed
      end
    else
      if (total-elapsed) <= 0
        retval = 1
      else
        retval = total-elapsed
      end
    end
    retval
  end
end