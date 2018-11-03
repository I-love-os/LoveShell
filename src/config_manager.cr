require "config"
require "tempfile"
require "file_utils"

class ConfigManager

  CONFIG_PATH = "/home/#{Process.user}/.config/LoveShell/LoveShell.conf"
  CONFIG_FOLDER = "/home/#{Process.user}/.config/LoveShell/"
  @@config

  DEFAULT_CONFIG =
    %(# LOVESHELL CONFIGURATION FILE

    key = value

    key = value

    key = value)

  def changeTheme(name : String)
    #tbd
  end

  def initConfig
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
  end

end
