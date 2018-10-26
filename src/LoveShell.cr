require "fancyline"
require "colorize"
require "user_group"

module LoveShell
  VERSION = "0.1.0"

 user = Process.user 
 hostname = System.hostname
 dir = Dir.current
 dir_with_tylda = "~#{dir.delete("/home/#{user}")}"



 prompt = "#{"[".colorize(:red)}#{user.colorize(:yellow)}#{"@".colorize(:red)}#{hostname.colorize(:yellow)}#{"]".colorize(:red)} #{dir_with_tylda.colorize.mode(:bold)}#{" ->".colorize(:light_red)} ".to_s
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
