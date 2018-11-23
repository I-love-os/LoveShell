require "./LoveShell"

class Channels
  enum Options
    Exit
    Reload
    Start
  end

  def initialize
    @channel = Channel(Options).new
    if @channel.receive == Options::Reload
      puts "WORKS"
    elsif @channel.receive == Options::Start
      shell = LoveShell::Shell.new
    end
  end

  def getOptionsStart : Options
    Options::Start
  end

  def getOptionsReload : Options
    Options::Reload
  end

  def send(option)
    @channel.send(option)
  end

end
