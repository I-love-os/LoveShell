require "colorize"
require "user_group"
require "./config_manager"

class Prompt
  @@config = LoveShell::CONFIG

  GIT_STATUS      = @@config.getGitStatus
  POWERLINE       = @@config.getPowerline
  FLOATING_PROMPT = @@config.getFloatingPrompt
  CLOCK           = @@config.getClock
  @git_dir = false

  def gitCheck
    if File.exists? Dir.current + "/.git/HEAD"
      @git_dir = true
    else
      @git_dir = false
    end
  end

  def git : String
    out = ""
    if Dir.exists? Dir.current + "/.git"
      if File.exists? Dir.current + "/.git/HEAD"
        git_config = File.read_lines(Dir.current + "/.git/HEAD")
        git_config.each do |line|
          if /^ref:/.match(line)
            @git_dir = true
            if POWERLINE == "on"
              case GIT_STATUS
              when "left"
                out = "#{"\u{e0a0}".colorize.fore(:black).back(:green)}\
                      #{line.split('/').last?.colorize.fore(:black).back(:green)}\
                      #{"\u{e0b0}".colorize(:green)}".to_s
              when "right"
                out = "#{"\u{e0b2}".colorize(:green)}\
                      #{"\u{e0a0}".colorize.fore(:black).back(:green)}\
                      #{line.split('/').last?.colorize.fore(:black).back(:green)}\
                      #{"\u{e0b0}".colorize(:green)}".to_s
              when "off"
                out = ""
              else
                out = "git_status: wrong config value (#{GIT_STATUS})".colorize(:red).mode(:bold).to_s
              end
            else
              out = "(#{line.split('/').last?})".colorize(:blue).to_s
            end
          else
            @git_dir = false
          end
        end
      end
    end
    out
  end

  def lovePrompt : String
    out = ""

    dev_prefix = ""

    if is_dev?
      prod_prefix = "(DEV) ".colorize.mode(:blink)
    end

    if POWERLINE == "on"
      gitCheck
      out = "#{prod_prefix}\
            #{FLOATING_PROMPT == "on" ? "\u{e0b2}".colorize(:red) : "\u{2588}".colorize(:red)}\
            #{Process.user.colorize.fore(:black).back(:red)}\
            #{"@".colorize.fore(:black).back(:red)}\
            #{System.hostname.colorize.fore(:black).back(:red)}\
            #{"\u{e0b0}".colorize.fore(:red).back(:yellow)}\
            #{Dir.current.sub("/home/#{Process.user}", "~").colorize.fore(:black).back(:yellow)}\
            #{GIT_STATUS == "left" && @git_dir == true ? "\u{e0b0}".colorize.fore(:yellow).back(:green) : "\u{e0b0}".colorize(:yellow)}\
            #{GIT_STATUS == "left" ? "#{git}" : ""}#{"\u{e0b1}".colorize(:light_red)} ".to_s
    else
      out = "#{prod_prefix}\
            #{"[".colorize(:red)}\
            #{Process.user.colorize(:yellow)}\
            #{"@".colorize(:red)}\
            #{System.hostname.colorize(:yellow)}\
            #{"] ".colorize(:red)}\
            #{Dir.current.sub("/home/#{Process.user}", "~").colorize.mode(:bold)}\
            #{GIT_STATUS == "left" ? " #{git}" : ""}\
            #{" ->".colorize(:light_red)} ".to_s
    end
    out
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
    "#{GIT_STATUS == "right" ? git : ""} #{time}"
  end

  def time : String
    out = ""
    ampmhour = 12
    ampm = ""
    time = Time.now
    if CLOCK == "24h"
      # That's the normal time format you scrubs.
    elsif CLOCK == "12h"
      ampmhour = time.hour % 12 if time.hour != 12 || time.hour != 24
      time.hour < 12 ? {ampm = "AM"} : {ampm = "PM"}
    end

    unless CLOCK == "off"
      CLOCK == "12h" ? {hours = ampmhour} : {hours = time.hour}
      if POWERLINE == "on"
        out = "\u{f017}#{hours < 10 ? "0" + hours.to_s : hours}:#{time.minute < 10 ? "0" + time.minute.to_s : time.minute}#{CLOCK == "12h" ? " #{ampm}" : ""} "
          .colorize(:light_gray).mode(:bold).to_s
      else
        out = "(#{hours < 10 ? "0" + hours.to_s : hours}:#{time.minute < 10 ? "0" + time.minute.to_s : time.minute}#{CLOCK == "12h" ? " #{ampm}" : ""}) "
          .colorize(:light_gray).mode(:bold).to_s
      end
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
