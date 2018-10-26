require "fancyline"
require "colorize"
require "user_group"
require "../src/prompt"

module LoveShell
  VERSION = "0.1.0"

  prompt = Prompt.new

  fancy = Fancyline.new

  fancy.display.add do |ctx, line, yielder|
    line = line.gsub(/^\w+/, &.colorize(:light_red).mode(:underline))
    line = line.gsub(/(\|\s*)(\w+)/) do
      "#{$1}#{$2.colorize(:light_red).mode(:underline)}"
    end

    line = line.gsub(/--?\w+/, &.colorize(:red))
    line = line.gsub(/"(?:[^"\\]|\\.)*"/, &.colorize(:red))

    yielder.call ctx, line
  end

  while input = fancy.readline(prompt.prompt)
    args = input.split(" ")
    break if input == "exit"
    
    if args[0] == "cd"
      Dir.cd(args[1].sub("~", "/home/#{Process.user}"))
    end

    system(input)
  end  
end
