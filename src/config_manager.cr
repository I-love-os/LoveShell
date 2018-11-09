require "config"
require "file_utils"

class ConfigManager
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
  @@config = Config.file(CONFIG_PATH)

  DEFAULT_CONFIG =
    %{# LOVESHELL CONFIGURATION FILE

    # Clock - Changes format of the clock displayed on the far right of the prompt.
    # Available values are "off", "24h", or "12h".

    clock: "24h",

    # Powerline - Uses iconic fonts (such as Powerline) to create a more visually appealing prompt.
    # Requires a patched font (I recommend Nerd Fonts: https://nerdfonts.com/)
    # Turn off or install a patched font if your prompt looks weird (blank rectangles, weird lines...).
    # Available values are "off", or "on".

    powerline: "on",

    # Floating prompt - (usable only with Powerline ON)
    # Is the float supposed to appear floating, or connected to the left side of the terminal.
    # Available values are "off", or "on".

    floating_prompt = "off",

    # Git Status - Shows the current Git branch if your current workinng directory is a Git repository.
    # If you're not a developer don't worry about this option.
    # Available values are "left", "right", or "off".

    git_status: "left"

    # History Length - dictates the length of you history file (located in ~/hit.love)
    # Available values are: any integer.

    hist_length: "3000"}

  def changeTheme(name : String)
    # tbd
  end

  def initialize
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
      @@config.as_s(key)
    rescue
      "-1"
    end
  end

  def getProperty(key : Nil) : String
    "Nil"
  end
end
