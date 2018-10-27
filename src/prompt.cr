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
		unless time.minute < 10
    	"(#{time.hour}:#{time.minute}) ".colorize(:light_gray).mode(:bold).to_s
		else
			"(#{time.hour}:0#{time.minute}) ".colorize(:light_gray).mode(:bold).to_s
		end
  end
end
