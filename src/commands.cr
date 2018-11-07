class Commands
  @@paths : Array(String) = ENV["PATH"].split(":")
  @@commands = [] of String

  def initialize
    getCommands
  end

  def getCommands : Array(String)
    @@paths.each do |path|
      next if !Dir.exists? path
      dir = Dir.new path
      dir.each do |file|
        @@commands << file if File.file? path + '/' + file
      end
    end
    @@commands
  end

  def grepCommands(input : String) : Array(String)
    grepd_commands = [] of String
    @@commands.each do |cmd|
      if /^#{input}/.match(cmd)
        grepd_commands << cmd
      end
    end
    grepd_commands
  end

  def exists?(command) : Bool
    if !command.empty?
      cmd_exists = false
      getCommands.each do |cmd|
        if command == cmd
          cmd_exists = true
        end
      end
      if (command.includes? '.') || (command.includes? '/')
        cmd_exists = true
      end
    else
      cmd_exists = true
    end

    cmd_exists
  end
end
