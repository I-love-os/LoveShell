require "colorize"
require "user_group"
require "./config_manager"

class Prompt

  @config = ConfigManager.new

  def git : String
    out = ""
    if Dir.exists? Dir.current + "/.git"
      if File.exists? Dir.current + "/.git/HEAD"
        git_config = File.read_lines(Dir.current + "/.git/HEAD")
        git_config.each do |line|
          if /^ref:/.match(line)
            out = "(#{line.split('/').last?})".colorize(:blue).to_s
          end
        end
      end
    end
    out
  end

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
     #{@config.getProperty("git_status") == "left" ? " #{git}" : ""}\
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

  def right : String
    "#{@config.getProperty("git_status") == "right" ? git : ""} #{time}"
  end

  def time : String
    out = ""
    ampmhour = 12
    ampm = ""
    time = Time.now
    if @config.getProperty("clock") == "24h"
      #That's the normal time format you scrubs.
    elsif @config.getProperty("clock") == "12h"
      ampmhour = time.hour % 12 if time.hour != 12 || time.hour != 24
      time.hour < 12 ? {ampm = "AM"} : {ampm = "PM"}
    end

    unless @config.getProperty("clock") == "off"
      @config.getProperty("clock") == "12h" ? {hours = ampmhour} : {hours = time.hour}
      out = "(#{hours < 10 ? "0" + hours.to_s : hours}:#{time.minute < 10 ? "0" + time.minute.to_s : time.minute}#{@config.getProperty("clock") == "12h" ? " #{ampm}" : ""}) "
      .colorize(:light_gray).mode(:bold).to_s
    else
      out = ""
    end
    out
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
