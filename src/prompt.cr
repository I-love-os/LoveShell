require "colorize"
require "user_group"

class Prompt	
	def prompt : String
    "#{"[".colorize(:red)}\
    #{Process.user.colorize(:yellow)}\
    #{"@".colorize(:red)}\
    #{System.hostname.colorize(:yellow)}\
    #{"] ".colorize(:red)}\
    #{Dir.current.sub("/home/#{Process.user}", "~").colorize.mode(:bold)}\
    #{" ->".colorize(:light_red)} ".to_s
  end
  
  def time : String
    time = Time.now
    "(#{time.hour}:#{time.minute}) ".colorize(:light_gray).mode(:bold).to_s
  end
end