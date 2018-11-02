require "colorize"
require "user_group"

class Prompt
  def lovePrompt : String

    dev_prefix = ""

    if is_dev?
        prod_prefix = "(DEV) ".colorize.mode(:blink)
    end

    "#{prod_prefix}\
    #{"[".colorize(:red)}\
    #{Process.user.colorize(:yellow)}\
    #{"@".colorize(:red)}\
    #{System.hostname.colorize(:yellow)}\
    #{"] ".colorize(:red)}\
    #{Dir.current.sub("/home/#{Process.user}", "~").colorize.mode(:bold)}\
    #{" ->".colorize(:light_red)} ".to_s
  end

  def wizardPrompt : String

    dev_prefix = ""

    if is_dev?
        prod_prefix = "(DEV) ".colorize.mode(:blink)
    end

    "#{prod_prefix}\
    #{"[".colorize(:red)}\
    #{"LOVESHELL SETTINGS".colorize(:magenta)}\
    #{"]".colorize(:red)}\
    #{" ->".colorize(:light_red)} ".to_s
  end

  def time : String
    time = Time.now
    "(#{time.hour < 10 ? "0" + time.hour.to_s : time.hour}:#{time.minute < 10 ? "0" + time.minute.to_s : time.minute}) "
    .colorize(:light_gray).mode(:bold).to_s
  end

  def is_dev? : Bool
    dev = false
    if ENV.has_key? "DEV"
      if ENV["DEV"].to_i == 1
        dev = true
      end
    end
    dev
  end
end
