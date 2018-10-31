require "fancyline"
require "colorize"
require "user_group"
require "option_parser"
require "./prompt"
require "./historian"

def get_command(ctx)
  line = ctx.editor.line
  cursor = ctx.editor.cursor.clamp(0, line.size - 1)
  pipe = line.rindex('|', cursor)
  line = line[(pipe + 1)..-1] if pipe

  line.split.first?
end

module LoveShell
  VERSION = "0.1.0"

  execute = false
  execute_block = ""
  pause = false

  aliases = {} of String => String

  prompt = Prompt.new
  fancy = Fancyline.new
  historian = Historian.new

  OptionParser.parse! do |parser|
    parser.banner = "Shell made with <3"
    parser.on("-x BLOCK", "--execute BLOCK", "Executes the specified code block.") {|block| execute = true; execute_block = block}
    parser.on("-p", "--pause", "(Usable only with -x) Shell doesn't exit after execution of the code block finishes.") {pause = true}
    parser.on("-h", "--help", "Shows this help.") {puts parser; exit(0)}
    parser.on("-v", "--version", "Prints LoveShell's version and exits.") {puts "LoveShell version #{VERSION}"; exit(0)}
    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  if execute == true
    system(execute_block)
    unless pause == true
      exit(0)
    end
  end


  fancy.display.add do |ctx, line, yielder|
    line = line.gsub(/^\w+/, &.colorize(:light_red).mode(:underline))
    line = line.gsub(/(\|\s*)(\w+)/) do
      "#{$1}#{$2.colorize(:light_red).mode(:underline)}"
    end

    line = line.gsub(/ --?\w+/, &.colorize(:magenta))
    line = line.gsub(/"(?:[^"\\]|\\.)*"/, &.colorize(:cyan))

    yielder.call ctx, line
  end


  help_line_enabled = true

  fancy.sub_info.add do |ctx, yielder|
    lines = yielder.call(ctx) # First run the next part of the middleware chain

    if (command = get_command(ctx)) && help_line_enabled # Grab the command
      help_line = `whatis #{command} 2> /dev/null`.lines.first?
      if help_line
        words = help_line.to_s.split(" ")
        words.delete("")

        line = ""
        words.map{|word| line = "#{line} #{word}" }

        lines << line
      else
        ctx.clear_info
      end
    end
    lines # Return the lines so far
  end

  #fancy.actions.set Fancyline::Key::Control::AltH do |ctx|
  #  if command = get_command(ctx)
  #    system("man #{command}")
  #  end
  #end

  fancy.actions.set Fancyline::Key::Control::AltH do |ctx|
    help_line_enabled = !help_line_enabled
    ctx.clear_info
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
      elsif args[0] == "alias"
        al = args[1].split "="
        args.delete args[0]
        func = args.join(" ").gsub(al[0] + "=", "")
        aliases[al[0]] = func[0] == '"' ? func.gsub '"', ("") : func[0] == '\'' ? func.gsub '\'', ("") : func
      elsif args[0] == "unalias"
        args.delete args[0]
        aliases.reject! args
      elsif aliases.has_key? args[0]
        args[0] = aliases[args[0]]
        system(args.join " ")
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
