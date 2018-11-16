require "colorize"
require "user_group"
require "./config_manager"

class Prompt
  @@config = LoveShell::CONFIG

  GIT_STATUS      = @@config.getGitStatus
  POWERLINE       = @@config.getPowerline
  FLOATING_PROMPT = @@config.getFloatingPrompt
  CLOCK           = @@config.getClock
  PL_STYLE        = @@config.getPLStyle
  MACHINE_COLOR   = @@config.getMachineColor
  DIR_COLOR       = @@config.getDirColor
  GIT_COLOR       = @@config.getGitColor
  FONT_COLOR      = @@config.getFontColor
  @git_dir = false

  LEFT_SYMBOL = begin
    case PL_STYLE
    when "sharp"
      "\u{e0b2}"
    when "round"
      "\u{e0b6}"
    when "pixels"
      "\u{e0c7}"
    when "ramp-up"
      "\u{e0ba}"
    when "ramp-down"
      "\u{e0be}"
    when "fire"
      "\u{e0c2}"
    when "trapezoid"
      "\u{e0d4}"
    else
      "\u{e0b2}"
    end
  end

  RIGHT_SYMBOL = begin
    case PL_STYLE
    when "sharp"
      "\u{e0b0}"
    when "round"
      "\u{e0b4}"
    when "pixels"
      "\u{e0c6}"
    when "ramp-up"
      "\u{e0bc}"
    when "ramp-down"
      "\u{e0b8}"
    when "fire"
      "\u{e0c0}"
    when "trapezoid"
      "\u{e0d2}"
    else
      "\u{e0b0}"
    end
  end

  PROMPT_SYMBOL = begin
    case PL_STYLE
    when "sharp"
      "\u{e0b1}"
    when "round"
      "\u{e0b5}"
    when "ramp-up"
      "\u{e0bb}"
    when "ramp-down"
      "\u{e0b9}"
    else
      "\u{e0b1}"
    end
  end

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
                out = "#{"\u{e0a0}".colorize.fore(FONT_COLOR).back(GIT_COLOR)}\
                      #{line.split('/').last?.colorize.fore(FONT_COLOR).back(GIT_COLOR)}\
                      #{RIGHT_SYMBOL.colorize(GIT_COLOR)}".to_s
              when "right"
                out = "#{LEFT_SYMBOL.colorize(GIT_COLOR)}\
                      #{"\u{e0a0}".colorize.fore(FONT_COLOR).back(GIT_COLOR)}\
                      #{line.split('/').last?.colorize.fore(FONT_COLOR).back(GIT_COLOR)}\
                      #{RIGHT_SYMBOL.colorize(GIT_COLOR)}".to_s
              when "off"
                out = ""
              else
                out = "git_status: wrong config value (#{GIT_STATUS})".colorize(MACHINE_COLOR).mode(:bold).to_s
              end
            else
              out = "(#{line.split('/').last?})".colorize(GIT_COLOR).to_s
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
            #{FLOATING_PROMPT == "on" ? LEFT_SYMBOL.colorize(MACHINE_COLOR) : "\u{2588}".colorize(MACHINE_COLOR)}\
            #{Process.user.colorize.fore(FONT_COLOR).back(MACHINE_COLOR)}\
            #{"@".colorize.fore(FONT_COLOR).back(MACHINE_COLOR)}\
            #{System.hostname.colorize.fore(FONT_COLOR).back(MACHINE_COLOR)}\
            #{RIGHT_SYMBOL.colorize.fore(MACHINE_COLOR).back(DIR_COLOR)}\
            #{Dir.current.sub("/home/#{Process.user}", "~").colorize.fore(FONT_COLOR).back(DIR_COLOR)}\
            #{GIT_STATUS == "left" && @git_dir == true ? RIGHT_SYMBOL.colorize.fore(DIR_COLOR).back(GIT_COLOR) : RIGHT_SYMBOL.colorize(DIR_COLOR)}\
            #{GIT_STATUS == "left" ? "#{git}" : ""}#{PROMPT_SYMBOL.colorize(MACHINE_COLOR)} ".to_s
    else
      out = "#{prod_prefix}\
            #{"[".colorize(MACHINE_COLOR)}\
            #{Process.user.colorize(DIR_COLOR)}\
            #{"@".colorize(MACHINE_COLOR)}\
            #{System.hostname.colorize(DIR_COLOR)}\
            #{"] ".colorize(MACHINE_COLOR)}\
            #{Dir.current.sub("/home/#{Process.user}", "~").colorize.mode(:bold)}\
            #{GIT_STATUS == "left" ? " #{git}" : ""}\
            #{" ->".colorize(MACHINE_COLOR)} ".to_s
    end
    out
  end

  def wizardPrompt : String
    dev_prefix = ""

    if is_dev?
      prod_prefix = "(DEV) ".colorize.mode(:blink)
    end

    "#{prod_prefix}\
    #{"[".colorize(MACHINE_COLOR)}\
    #{"LOVESHELL SETTINGS".colorize(:magenta)}\
    #{"]".colorize(MACHINE_COLOR)}\
    #{" ->".colorize(MACHINE_COLOR)} ".to_s
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
