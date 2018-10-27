require "fancyline"
require "colorize"
require "user_group"
require "./prompt"
require "./historian"

module LoveShell
  VERSION = "0.1.0"

  prompt = Prompt.new
  fancy = Fancyline.new
  historian = Historian.new

  fancy.display.add do |ctx, line, yielder|
    line = line.gsub(/^\w+/, &.colorize(:light_red).mode(:underline))
    line = line.gsub(/(\|\s*)(\w+)/) do
      "#{$1}#{$2.colorize(:light_red).mode(:underline)}"
    end

    line = line.gsub(/ --?\w+/, &.colorize(:magenta))
    line = line.gsub(/"(?:[^"\\]|\\.)*"/, &.colorize(:cyan))

    yielder.call ctx, line
  end

  fancy.actions.set Fancyline::Key::Control::CtrlC do |ctx|
    #Do Nothing
  end

  Signal::INT.trap do
    #Do Nothing
  end

  fancy.actions.set Fancyline::Key::Control::CtrlD do |ctx|
    #Do Nothing
  end

  fancy.actions.set Fancyline::Key::Control::Up do |ctx|
    while true
      break if historian.getEntryUp[0..3] != "#<3#"
      if historian.getLength == historian.getPosition + 1
        historian.getEntryDown
        break
      end
    end
    ctx.editor.line = historian.getCurrentEntry
  end

  fancy.actions.set Fancyline::Key::Control::Down do |ctx|
    while true
      break if historian.getEntryDown[0..3] != "#<3#"
    end
    ctx.editor.line = historian.getCurrentEntry
  end

  historian.log(%(#<3# Opened LoveShell instance with PID ) + "#{Process.pid}" + " on " + "#{Time.now}")

  begin
    while input = fancy.readline(prompt.prompt, rprompt: prompt.time)
      historian.log(input)
      historian.resetPosition
      args = input.split(" ")
      break if input == "exit"

      if args[0] == "cd"
        begin
          Dir.cd(args[1].sub("~", "/home/#{Process.user}"))
        rescue exception
          puts exception
        end
      else
        system(input)
      end
    end
    historian.log(%(#<3# Closed LoveShell instance with PID ) + "#{Process.pid}" + " on " + "#{Time.now}")
  rescue err : Fancyline::Interrupt
    puts "<3".colorize(:red).mode(:bold)
    historian.log(%(#<3# LoveShell instance with PID ) + "#{Process.pid}" + " interrupted on " + "#{Time.now}")
  end
end
