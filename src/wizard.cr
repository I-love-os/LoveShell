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
        puts "Because of how LoveShell manages it's config, \
        you need to restart it for the changes to take effect." if @changes == true
        break
      end
      parse(args[0].to_s, args[1].to_s, args[2])
    end
  end

  def parse(command : String, key : String, value)
    key = key.to_s.downcase
    case command.to_s.upcase
    when "REGEN", "REGENERATE", "RESET"
      if key == ""
        puts "Regenerate what?"
      elsif key == "config" || key == "configuration" || key == "settings"
        @config.regenConfig
        @changes = true
      elsif key == "colors" || key == "color" || key == "schemes" || key == "colorschemes"
        @config.regenSchemes
        @changes = true
      else
        puts "You can't regenerate that!"
      end
    when "HELP"
      puts "not gonna help you lol"
    when "GET", "LOAD", "READ"
      if key == ""
        puts "Get what?"
      else
        puts @config.getProperty(key)
      end
    when "SET", "SAVE", "WRITE"
      if key == ""
        puts "Set what?"
      elsif key == "color" || key == "colors" || key == "machine_color" || key == "dir_color" || key == "git_color" || key == "git_diff_color" || key == "font_color" && key != "colorscheme"
        puts "Changing colors from this prompt is not supported. Use our dedicated app to do that, or just change the color scheme."
      elsif value == ""
        puts "Set #{key} to what?"
      else
        @config.setProperty(key, value)
        @changes = true
      end
    else
      puts "No such command."
    end
  end
end
