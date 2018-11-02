require "fancyline"
require "./prompt"
require "./config"

class Wizard

  @fancy = Fancyline.new
  @prompt = Prompt.new
  @config = Config.new

  def start
    @config.initConfig
    while input = @fancy.readline(@prompt.wizardPrompt)
      args = input.split(" ")
      break if input == "exit"
      parse(args[0], args.size > 1 ? args[1] : nil)
    end
  end

  def parse(key : String, value : String? = nil)
    puts "Key: #{key}, Value: #{value}"
  end
end
