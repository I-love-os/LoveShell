require "config"
require "file_utils"
require "colorize"

class ConfigManager

  @clock : String
  @powerline : String
  @floating_prompt : String
  @git_status : String
  @pl_style : String
  @hist_length : Int32

  CONFIG_PATH   = "/home/#{Process.user}/.config/LoveShell/LoveShell.conf"
  CONFIG_FOLDER = "/home/#{Process.user}/.config/LoveShell/"

  if !File.exists?(CONFIG_PATH)
    puts "No configuration file found. Creating a new one..."
    if !File.directory?(CONFIG_FOLDER)
      puts "No config directory found. Creating #{CONFIG_FOLDER}..."
      FileUtils.mkdir(CONFIG_FOLDER)
    end
    file = File.new(CONFIG_PATH, "w+")
    puts "Would you like to populate it with default settings? (Y/N): "
    while true
      ans = gets.to_s.chomp.upcase
      case ans
      when "Y"
        puts "gonna do it xd"
        file.puts DEFAULT_CONFIG
        break
      when "N"
        puts "not gonna do it xd"
        file.puts "#<3# LOVESHELL CONFIGURATION FILE"
        break
      else
        puts "y or n pls"
      end
    end
    file.close
  end
  CONFIG = Config.file(CONFIG_PATH)

  DEFAULT_CONFIG =
    %[# LOVESHELL CONFIGURATION FILE

    # Clock - Changes format of the clock displayed on the far right of the prompt.
    # Available values are "off", "24h", or "12h".

    clock: "24h"

    # Powerline - Uses iconic fonts (such as Powerline) to create a more visually appealing prompt.
    # Requires a patched font (I recommend Nerd Fonts: https://nerdfonts.com/)
    # Turn off or install a patched font if your prompt looks weird (blank rectangles, weird lines...).
    # Available values are "off", or "on".

    powerline: "on"

    # Powerline Style - What style of separators and symbols should the prompt use.
    # Requires a font patched with Powerline Extra Symbols (Go download a Nerd Font already: https://nerdfonts.com/)
    # Usable only with Powerline ON
    # Available values are "sharp", "round", "pixels", "ramp-up", "ramp-down", "fire", "trapezoid".

    pl_style: "sharp"

    # Floating prompt - (usable only with Powerline ON)
    # Is the prompt supposed to appear detached, or connected to the left side of the terminal.
    # Available values are "off", or "on".

    floating_prompt = "off"

    # Git Status - Shows the current Git branch if your current workinng directory is a Git repository.
    # If you're not a developer don't worry about this option.
    # Available values are "left", "right", or "off".

    git_status: "left"

    # History Length - dictates the length of you history file (located in ~/hist.love)
    # Available values are: any integer.

    hist_length: 3000

    # Custom colors in hex RGB values, for example: "#FF0000" is red

    colors: {
      machine_color: "#E06C75"
      dir_color: "#D19A66"
      git_color: "#98C379"
      git_diff_color: "#ffff6e"
      font_color: "#000000"
    }]

  def initialize
    @clock = begin CONFIG.as_s("clock") rescue "24h" end
    @powerline = begin CONFIG.as_s("powerline") rescue "off" end
    @floating_prompt = begin CONFIG.as_s("floating_prompt") rescue "off" end
    @git_status = begin CONFIG.as_s("git_status") rescue "off" end
    @pl_style = begin CONFIG.as_s("pl_style") rescue "sharp" end
    @hist_length = begin CONFIG.as_i("hist_length") rescue -1 end

    @machine_color = Colorize::ColorRGB.new(getColor("machine_color")[0], getColor("machine_color")[1], getColor("machine_color")[2])
    @dir_color = Colorize::ColorRGB.new(getColor("dir_color")[0], getColor("dir_color")[1], getColor("dir_color")[2])
    @git_color = Colorize::ColorRGB.new(getColor("git_color")[0], getColor("git_color")[1], getColor("git_color")[2])
    @git_diff_color = Colorize::ColorRGB.new(getColor("git_diff_color")[0], getColor("git_diff_color")[1], getColor("git_diff_color")[2])
    @font_color = Colorize::ColorRGB.new(getColor("font_color")[0], getColor("font_color")[1], getColor("font_color")[2])
  end

  def regenConfig
    puts "Are you sure you want to regenerate the config file? All your LoveShell settings will be reset. (Y/N): "
    while true
      ans = gets.to_s.chomp.upcase
      case ans
      when "Y"
        puts "Backing up your current config at #{CONFIG_PATH}.old..."
        FileUtils.mv(CONFIG_PATH, "#{CONFIG_PATH}.old")
        file = File.new(CONFIG_PATH, "w+")
        file.puts DEFAULT_CONFIG
        file.close
        break
      when "N"
        puts "not gonna do it xd"
        break
      else
        puts "y or n pls"
      end
    end
  end

  def getProperty(key : String) : String
    begin
      CONFIG.as_s(key)
    rescue
      getPropertyInt(key)
    end
  end

  def getPropertyInt(key : String)
    begin
      CONFIG.as_i(key).to_s
    rescue
      getPropertyHash(key)
    end
  end

  def getPropertyHash(key : String)
    begin
      CONFIG.as_h(key).to_s
    rescue
      "Error"
    end
  end

  def getProperty(key : Nil) : String
    "Nil"
  end

  def getClock
    @clock
  end

  def getHistLength
    @hist_length
  end

  def getPowerline
    @powerline
  end

  def getFloatingPrompt
    @floating_prompt
  end

  def getGitStatus
    @git_status
  end

  def getPLStyle
    @pl_style
  end

  def getColor(color : String)
    hex = begin CONFIG.as_h("colors")[color].to_s.downcase rescue "#000000" end
    r = hex.byte_slice(1, 2).to_u8(16)
    g = hex.byte_slice(3, 2).to_u8(16)
    b = hex.byte_slice(5, 2).to_u8(16)
    [r, g, b]
  end

  def getMachineColor
    @machine_color
  end

  def getDirColor
    @dir_color
  end

  def getGitColor
    @git_color
  end

  def getGitDiffColor
    @git_diff_color
  end

  def getFontColor
    @font_color
  end
end
