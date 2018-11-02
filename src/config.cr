class Config

  CONFIG_PATH = "/home/#{Process.user}/.config/LoveShell/config"

  def changeTheme(name : String)
    #tbd
  end

  def initConfig
    if !File.exists?(CONFIG_PATH) || File.empty?(CONFIG_PATH)
      puts "No configuration file found or the file is empty. Generating a new one..."
      #sike, not really (at least not yet)
    end
  end

end
