require "fancyline"
require "colorize"

module LoveShell
  VERSION = "0.1.0"
  
 prompt = "(~): ".colorize(:red).to_s
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

  while input = fancy.readline(prompt)
    break if input == "exit"
    

    system(input)
  end  
end
