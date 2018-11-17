require "fancyline"
require "./prompt"
require "./config_manager"

class Wizard
  @fancy = Fancyline.new
  @prompt = Prompt.new
  @config = LoveShell::CONFIG

  @changes = false

  def start
    while input = @fancy.readline(@prompt.wizardPrompt)
      args = input.split(" ")
      if args.size == 2
        args << ""
      elsif args.size == 1
        args << "" << ""
      end
      if input == "exit"
        puts "Because of how LoveShell manages it's config,\
         you need to restart it for the changes to take effect." if @changes == true
        break
      end
      parse(args[0].to_s, args[1].to_s, args[2])
    end
  end

  def parse(command : String, key : String, value)
    case command.to_s.upcase
    when "REGEN", "REGENERATE", "RESET"
      @config.regenConfig
      @changes = true
    when "HELP"
      puts "not gonna help you lol"
    when "GET", "LOAD", "READ"
      if key == ""
        puts "Get what?"
      else
        puts @config.getProperty(key.to_s.downcase)
      end
    when "SET", "SAVE", "WRITE"
      if key == ""
        puts "Set what?"
      elsif value == ""
        puts "Set #{key} to what?"
      else
        @config.setProperty(key.to_s.downcase, value)
        @changes = true
      end
    else
      puts "No such command."
    end
  end
end
