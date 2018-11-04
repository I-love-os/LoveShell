require "fancyline"
require "./prompt"
require "./config_manager"

class Wizard

  @fancy = Fancyline.new
  @prompt = Prompt.new
  @config = ConfigManager.new

  def start
    while input = @fancy.readline(@prompt.wizardPrompt)
      args = input.split(" ")
      if args.size < 2
        args << ""
      end
      break if input == "exit"
      parse(args[0].to_s, args[1].to_s)
    end
  end

  def parse(key : String, value : String)
    case key.to_s.upcase
    when "REGEN", "REGENERATE", "RESET"
      @config.regenConfig
    when "HELP"
      puts "not gonna help you lol"
    when "GET", "READ"
      if value == ""
        puts "Get what?"
      else
        puts @config.getProperty(value.to_s.downcase)
      end
    else
      puts "No such command."
    end
  end
end
