require "config"
require "file_utils"
require "colorize"

class ConfigManager

  @clock : String
  @powerline : String
  @floating_prompt : String
  @git_status : String
  @pl_style : String
  @help_line : String
  @help_tip : String
  @legacy_symbol : String
  @translate: String
  @color_scheme : String
  @hist_length : Int32

  @machine_color : (Colorize::ColorRGB | Symbol)
  @dir_color : (Colorize::ColorRGB | Symbol)
  @git_color : (Colorize::ColorRGB | Symbol)
  @git_diff_color : (Colorize::ColorRGB | Symbol)
  @font_color : (Colorize::ColorRGB | Symbol)


  CONFIG_PATH   = "#{ENV["HOME"]}/.config/Love/shell.conf"
  SCHEMES_PATH  = "#{ENV["HOME"]}/.config/Love/schemes.conf"
  CONFIG_FOLDER = "#{ENV["HOME"]}/.config/Love/"
  NO_TRUECOLOR  = begin !ENV["TERM"].includes?("256color") rescue false end



  if NO_TRUECOLOR
    puts "The terminal you're using doesn't support true color. Forcing the no_truecolor color scheme."
  end

  if !File.directory?(CONFIG_FOLDER)
    puts "No config directory found. Creating #{CONFIG_FOLDER}..."
    FileUtils.mkdir(CONFIG_FOLDER)
  end

  if !File.exists?(CONFIG_PATH)
    puts "No configuration file found. Creating a new one..."
    File.write(CONFIG_PATH, DEFAULT_CONFIG)
    puts "Populating it with default settings..."
  end

  if !File.exists?(SCHEMES_PATH)
    puts "No color scheme file found. Creating a new one..."
    File.write(SCHEMES_PATH, DEFAULT_SCHEMES)
    puts "Populating it with default color schemes..."
  end

  CONFIG = Config.file(CONFIG_PATH)
  SCHEMES = Config.file(SCHEMES_PATH)

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

    # Help line - Shows a quick summary of the command under the prompt.
    # It can be toggled on the fly using Alt+H, but you can change the default state here
    # Available values are "off", or "on".

    help_line: "on"

    # Help tip - Toggles the visibility of the "Ctrl+H for more info" tooltip when the help line is enabled.
    # Available values are "off", or "on".

    help_tip: "on"

    # Legacy symbol - Should the traditional prompt symbol ($ or #) be visible at the end of the prompt.
    # Available values are "off" or "on".

    legacy_symbol: "off"

    # Translate - The shell will try to translate whatis and man into your language of choice.

    translate: "on"

    # History Length - dictates the length of you history file (located in ~/hist.love)
    # Available values are: any integer.

    hist_length: 3000

    # Color scheme - you can change the color scheme LoveShell uses.
    # List of available color schemes is available in ~/.config/Love/schemes.conf

    color_scheme: "default"]

  DEFAULT_SCHEMES =
    %[# Custom colors in hex RGB values, for example: "#FF0000" is red

    default: {
      machine_color: "#E06C75"
      dir_color: "#D19A66"
      git_color: "#98C379"
      git_diff_color: "#ffff6e"
      font_color: "#000000"
    }

    sakura: {
      machine_color: "#FE87AC"
      dir_color: "#FECBCF"
      git_color: "#CFE4DD"
      git_diff_color: "#FAF0EF"
      font_color: "#5E556A"
    }

    cupcake: {
      machine_color: "#f2e2cf"
      dir_color: "#fa556b"
      git_color: "#907d6f"
      git_diff_color: "#ffb456"
      font_color: "#810c13"
    }

    lime: {
      machine_color: "#84b000"
      dir_color: "#ebe7c3"
      git_color: "#a8aec1"
      git_diff_color: "#776477"
      font_color: "#003d00"
    }

    wheat: {
      machine_color: "#7b297d"
      dir_color: "#e87888"
      git_color: "#eae8e5"
      git_diff_color: "#eec48b"
      font_color: "#2b0549"
    }

    royal: {
      machine_color: "#57898a"
      dir_color: "#b3b89a"
      git_color: "#ccae66"
      git_diff_color: "#cb9362"
      font_color: "#495049"
    }

    blueberry: {
      machine_color: "#6e819e"
      dir_color: "#d0aebc"
      git_color: "#508b00"
      git_diff_color: "#f6f4f5"
      font_color: "#213451"
    }

    # If your terminal doesn't support true color, LoveShell will use these
    # so it can still offer syntax highlighting feaures.

    no_truecolor: {
      machine_color: "red"
      dir_color: "yellow"
      git_color: "green"
      git_diff_color: "light-yellow"
      font_color: "black"
    }]

  def initialize
    @clock = begin CONFIG.as_s("clock") rescue setProperty("clock", "on", true).to_s end
    @powerline = begin CONFIG.as_s("powerline") rescue setProperty("powerline", "off", true).to_s end
    @floating_prompt = begin CONFIG.as_s("floating_prompt") rescue setProperty("floating_prompt", "off", true).to_s end
    @git_status = begin CONFIG.as_s("git_status") rescue setProperty("git_status", "left", true).to_s end
    @pl_style = begin CONFIG.as_s("pl_style") rescue setProperty("pl_style", "sharp", true).to_s end
    @help_line = begin CONFIG.as_s("help_line") rescue setProperty("help_line", "on", true).to_s end
    @help_tip = begin CONFIG.as_s("help_tip") rescue setProperty("help_tip", "on", true).to_s end
    @legacy_symbol = begin CONFIG.as_s("legacy_symbol") rescue setProperty("legacy_symbol", "off", true).to_s end
    @translate = begin CONFIG.as_s("translate") rescue setProperty("translate", "on", true).to_s end
    @color_scheme = begin CONFIG.as_s("color_scheme") rescue setProperty("color_scheme", "default", true).to_s end
    @hist_length = begin CONFIG.as_i("hist_length") rescue setProperty("hist_length", 3000, true).to_s.to_i end

    machine_rgb = getColor("machine_color")
    dir_rgb = getColor("dir_color")
    git_rgb = getColor("git_color")
    git_diff_rgb = getColor("git_diff_color")
    font_rgb =getColor("font_color")

    @machine_color = NO_TRUECOLOR ? getNoTrueColor("machine_color") : Colorize::ColorRGB.new(machine_rgb[0], machine_rgb[1], machine_rgb[2])
    @dir_color = NO_TRUECOLOR ? getNoTrueColor("dir_color") : Colorize::ColorRGB.new(dir_rgb[0], dir_rgb[1], dir_rgb[2])
    @git_color = NO_TRUECOLOR ? getNoTrueColor("git_color") : Colorize::ColorRGB.new(git_rgb[0], git_rgb[1], git_rgb[2])
    @git_diff_color = NO_TRUECOLOR ? getNoTrueColor("git_diff_color") : Colorize::ColorRGB.new(git_diff_rgb[0], git_diff_rgb[1], git_diff_rgb[2])
    @font_color = NO_TRUECOLOR ? getNoTrueColor("font_color") : Colorize::ColorRGB.new(font_rgb[0], font_rgb[1], font_rgb[2])

    if ENV["TERM"] == "linux" && @powerline == "on"
      puts "You're using a tty terminal, forcing powerline off."
      @powerline = "off"
    end
  end

  def regenConfig
    puts "Are you sure you want to regenerate the config file? All your LoveShell settings will be reset, but a backup will be made. (Y/N): "
    while true
      ans = gets.to_s.chomp.upcase
      case ans
      when "Y"
        puts "Backing up your current config at #{CONFIG_PATH}.old..."
        FileUtils.mv(CONFIG_PATH, "#{CONFIG_PATH}.old")
        File.write(CONFIG_PATH, DEFAULT_CONFIG)
        break
      when "N"
        puts "Regen cancelled."
        break
      else
        puts "Answer by typing 'Y' or 'N'."
      end
    end
  end

  def regenSchemes
    puts "Are you sure you want to regenerate the color scheme file? All your custom color schemes will be deleted, but a backup will be made. (Y/N): "
    while true
      ans = gets.to_s.chomp.upcase
      case ans
      when "Y"
        puts "Backing up your current color scheme file at #{SCHEMES_PATH}.old..."
        FileUtils.mv(SCHEMES_PATH, "#{SCHEMES_PATH}.old")
        File.write(SCHEMES_PATH, DEFAULT_SCHEMES)
        break
      when "N"
        puts "Regen cancelled."
        break
      else
        puts "Answer by typing 'Y' or 'N'."
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

  def setProperty(key : String, value, re : Bool = false)
    value = begin value.to_i rescue value.to_s end
    xd = ""
    config_array = File.read_lines(CONFIG_PATH)
    regex = Regex.new(key + ":")
    index = config_array.index { |i| i =~ regex}
    unless index.nil?
      if value.class == String
        config_array[index] = %[    #{key}: "#{value}"]
      else
        config_array[index] = %[    #{key}: #{value}]
      end
      puts "Set #{key} (at line #{index + 1}) to #{value}."
    else
      if value.class == String
        config_array << "" << %[    #{key}: "#{value}"]
      else
        config_array << "" << %[    #{key}: #{value}]
      end
      puts "Key #{key} not found in the config file. Adding it at line #{config_array.size} and setting it to #{value}."
    end
    xd = String.build do |str|
      config_array.each { |e| str = str << e << "\n"}
    end
    File.write(CONFIG_PATH, xd)
    return value if re
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

  def getHelpLine
    @help_line
  end

  def getHelpTip
    @help_tip
  end

  def getLegacySymbol
    @legacy_symbol
  end

  def getTranslate
    @translate
  end

  def getColorScheme
    @color_scheme
  end

  def getColor(color : String)
    hex = begin
      SCHEMES.as_h(@color_scheme)[color].to_s.downcase
    rescue
      puts %[Couldn't find color "#{color}" in the "#{@color_scheme}" color scheme. Either there's no such color scheme, or the color is not defined in that color scheme. Using black (#000000) instead.]
      "#000000"
    end
    r = hex.byte_slice(1, 2).to_u8(16)
    g = hex.byte_slice(3, 2).to_u8(16)
    b = hex.byte_slice(5, 2).to_u8(16)
    [r, g, b]
  end

  def getNoTrueColor(color : String)
    begin
      x = SCHEMES.as_h("no_truecolor")[color].to_s.downcase
      case x
      when "black"
        :black
      when "white"
        :white
      when "red"
        :red
      when "green"
        :green
      when "yellow"
        :yellow
      when "blue"
        :blue
      when "magenta"
        :magenta
      when "cyan", "aqua"
        :cyan
      when "light-gray", "light-grey"
        :light_grey
      when "dark-gray", "dark-grey"
        :dark_grey
      when "light-red"
        :light_red
      when "light-green"
        :light_green
      when "light-yellow"
        :light_yellow
      when "light-blue"
        :light_blue
      when "light-magenta"
        :light_magenta
      when "light-cyan", "light-aqua"
        :light_cyan
      else
        :black
      end
    rescue
      puts %[Couldn't find color "#{color}" in the alternative non-truecolor color scheme. That means there's probably an error in the schemes file. Using "black" instead.]
      :black
    end
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
