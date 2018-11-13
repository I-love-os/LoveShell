require "io"
require "option_parser"
require "colorize"
require "fancyline"
require "user_group"
require "./prompt"
require "./historian"
require "./commands"
require "./wizard"
require "./config_manager"

def get_command(ctx)
  line = ctx.editor.line
  cursor = ctx.editor.cursor.clamp(0, line.size - 1)
  pipe = line.rindex('|', cursor)
  line = line[(pipe + 1)..-1] if pipe

  line.split.first?
end

module LoveShell
  VERSION = "0.2.0"

  execute = false
  execute_block = ""
  pause = false
  settings = false

  aliases = {"ls" => "ls --color=auto", "lsa" => "ls --color=auto -a", "grep" => "grep --color"} of String => String

  prompt = Prompt.new
  fancy = Fancyline.new
  historian = Historian.new
  commands = Commands.new
  wizard = Wizard.new
  CONFIG = ConfigManager.new

  # ARGUMENT PARSING

  OptionParser.parse! do |parser|
    parser.banner = "Shell made with <3"
    parser.on("-x BLOCK", "--execute BLOCK", "Executes the specified code block.") { |block| execute = true; execute_block = block }
    parser.on("-s", "--settings", "Launches the LoveShell Settings prompt.") { settings = true }
    parser.on("-p", "--pause", "(Usable with -x or -s) Shell doesn't exit after execution of the task finishes.") { pause = true }
    parser.on("-h", "--help", "Shows this help.") { puts parser; exit(0) }
    parser.on("-v", "--version", "Prints LoveShell's version and exits.") { puts "LoveShell version #{VERSION}"; exit(0) }
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

  if settings == true
    wizard.start
    unless pause == true
      exit(0)
    end
  end

  # COLORING INPUT

  fancy.display.add do |ctx, line, yielder|
    line = line.gsub(/^[A-Za-z0-9-\--_]*/, &.colorize(:light_red).mode(:bold))
    line = line.gsub(/(\|\s*)([A-Za-z0-9-]*)/) do
      "#{$1}#{$2.colorize(:light_red).mode(:bold)}"
    end

    line = line.gsub(/ --?[A-Za-z0-9-\--_]*/, &.colorize(:magenta))
    line = line.gsub(/"(?:[^"\\]|\\.)*"/, &.colorize(:cyan).mode(:underline))

    yielder.call ctx, line
  end

  # HELP LINE

  help_line_enabled = true

  fancy.sub_info.add do |ctx, yielder|
    lines = yielder.call(ctx) # First run the next part of the middleware chain

    if (command = get_command(ctx)) && help_line_enabled # Grab the command
      if (!command.includes? "\"") && (!command.includes? "\'") && (!command.includes? "\(") && (!command.includes? "\)") && (!command.includes? "&&&")  && (!command.includes? ";;") 
        help_line = `whatis #{command} 2> /dev/null`.lines.first?
        if help_line
          words = help_line.to_s.split(" ")
          words.delete("")

          line = ""
          words.map { |word| line = "#{line} #{word}" }

          lines << line
        else
          ctx.clear_info
        end
      end
    end
    lines # Return the lines so far
  end

  # AUTOCOMPLETION

  fancy.autocomplete.add do |ctx, range, word, yielder|
    completions = yielder.call(ctx, range, word)
    prev_char = ctx.editor.line[ctx.editor.cursor - 1]?

    arg_begin = ctx.editor.line.rindex(' ', ctx.editor.cursor - 1) || 0
    arg_end = ctx.editor.line.index(' ', arg_begin + 1) || ctx.editor.line.size
    range = (arg_begin + 1)...arg_end

    if (get_command(ctx) != ctx.editor.line[arg_begin...arg_end].strip) && ctx.editor.line[arg_begin...arg_end] != "" || {'/', '.'}.includes?(prev_char)
      path = ctx.editor.line[range].strip
    elsif ctx.editor.line[arg_begin...arg_end] != ""
      command = ctx.editor.line[arg_begin...arg_end].strip
    end

    if path
      path = path.sub("~", "/home/#{Process.user}")
      Dir["#{path}*"].each do |suggestion|
        base = File.basename(suggestion)
        suggestion += '/' if Dir.exists? suggestion
        completions << Fancyline::Completion.new(range, suggestion.sub("/home/#{Process.user}", "~"), base)
      end
    end

    if command
      commands.grepCommands(command).uniq.each do |suggestion|
        completions << Fancyline::Completion.new(range, suggestion[1...suggestion.size], suggestion)
      end
    end

    completions
  end

  # MISC KEYBINDS

  # fancy.actions.set Fancyline::Key::Control::AltH do |ctx|
  #  if command = get_command(ctx)
  #    system("man #{command}")
  #  end
  # end

  fancy.actions.set Fancyline::Key::Control::AltH do |ctx|
    help_line_enabled = !help_line_enabled
    ctx.clear_info
  end
  fancy.actions.set Fancyline::Key::Control::CtrlC do |ctx|
    # Do Nothing
  end

  Signal::INT.trap do
    # Do Nothing
  end

  fancy.actions.set Fancyline::Key::Control::CtrlD do |ctx|
    # Do Nothing
  end

  fancy.actions.set Fancyline::Key::Control::CtrlR do |ctx|
    # No default history search for you
  end

  # HISTORY CONTROL

  fancy.actions.set Fancyline::Key::Control::Up do |ctx|
    historian.saveLine(ctx.editor.line) if historian.getPosition == -1
    ctx.editor.line = historian.getEntryUp
    ctx.editor.move_cursor(ctx.editor.line.size)
  end

  fancy.actions.set Fancyline::Key::Control::Down do |ctx|
    ctx.editor.line = historian.getEntryDown
    ctx.editor.move_cursor(ctx.editor.line.size)
  end

  # THE MAIN LOOP

  historian.log(%(#<3# Opened LoveShell instance with PID ) + "#{Process.pid}" + " on " + "#{Time.now}")

  begin
    while input = fancy.readline(prompt.lovePrompt, rprompt: prompt.right)
      historian.log(input)
      historian.resetPosition
      args = input.split(" ")
      break if input == "exit"

      als = [] of Int32
      args.each_index { |x| als << x if aliases.has_key? args[x] }

      if args[0] == "cd"
        begin
          Dir.cd(args[1].sub("~", "/home/#{Process.user}"))
        rescue exception
          puts exception
        end
      elsif args[0] == "export"
        ex = args[1].split "="
        ENV[ex[0].to_s] = ex[1].to_s
      elsif args[0] == "alias"
        al = args[1].split "="
        args.delete args[0]
        func = args.join(" ").gsub(al[0] + "=", "")
        aliases[al[0]] = func[0] == '"' ? func.gsub '"', ("") : func[0] == '\'' ? func.gsub '\'', ("") : func
      elsif args[0] == "unalias"
        args.delete args[0]
        aliases.reject! args
      elsif !als.empty?
        als.each { |x| args[x] = aliases[args[x]] }
        system(args.join " ")
      elsif args[0] == "SETTINGS" || args[0] == "CONFIG" || args[0] == "WIZARD"
        wizard.start
      elsif !commands.exists? args[0]
        puts "LoveShell".colorize(:magenta).to_s +
             ":".colorize.mode(:bold).to_s +
             " Command ".colorize(:yellow).to_s +
             %(").colorize.mode(:bold).to_s +
             args[0].colorize(:red).mode(:bold).to_s +
             %(" ).colorize.mode(:bold).to_s +
             "not found".colorize(:yellow).to_s +
             "!".colorize(:red).to_s
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
