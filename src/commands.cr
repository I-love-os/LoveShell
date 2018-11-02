class Commands
  @@paths : Array(String) = ENV["PATH"].split(":")
  @@commands = [] of String

  def initialize
    @@paths.each do |path|
      next if !Dir.exists? path
      dir = Dir.new path
      dir.each do |file|
        @@commands << file if File.file? path + '/' + file
      end
    end
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
end
