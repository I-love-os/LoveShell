class Historian

  HISTORY_PATH = "#{ENV["HOME"]}/.hist.love"
  HIST_LENGTH = LoveShell::CONFIG.getHistLength
  @@position = -1
  @@savedLine = ""

  def log(message : String)
    unless File.exists?(HISTORY_PATH)
      histfile = File.new(HISTORY_PATH, "w+")
      histfile.puts("#<3# LOG START")
      histfile.close
    end

    xd = ""
    histarray = File.read_lines(HISTORY_PATH)
    if HIST_LENGTH < 0
      # Don't do anything with the history atm
    else
      if histarray.size >= HIST_LENGTH
        histarray.delete_at(0)
        xd = String.build do |str|
          histarray.each { |e| str << e << "\n"}
        end
        File.write(HISTORY_PATH, xd)
      end
    end
    if message != ""
      histfile = File.new(HISTORY_PATH, "a")
      histfile.puts(message)
      histfile.close
    end
  end

  def getEntryUp : String
    histLength = File.read_lines(HISTORY_PATH).size - 1
    histLog = File.read_lines(HISTORY_PATH).reverse
    unless @@savedLine == ""
      while true
        @@position += 1
        out = histLog[@@position].to_s
        break if out[0..@@savedLine.size - 1] == @@savedLine
        if getLength == getPosition + 1
          @@position -= 1
          break
        end
      end
    else
      while true
        @@position += 1
        out = histLog[@@position].to_s
        break if out[0..3] != "#<3#"
        if getLength == getPosition + 1
          @@position -= 1
          break
        end
      end
    end
    out
  end

  def getEntryDown : String
    histLog = File.read_lines(HISTORY_PATH).reverse
    unless @@savedLine == ""
      while true
        @@position -= 1
        if @@position < 0
          @@position = -1
          out = @@savedLine
          break
        end
        out = histLog[@@position].to_s
        break if out[0..@@savedLine.size - 1] == @@savedLine
      end
      out
    else
      while true
        @@position -= 1
        if @@position < 0
          @@position = -1
          out = ""
          break
        end
        out = histLog[@@position].to_s
        break if out[0..3] != "#<3#"
      end
      out
    end
  end

  def getCurrentEntry : String
    if @@position == -1
      out = ""
    else
      histLog = File.read_lines(HISTORY_PATH).reverse
      out = histLog[@@position].to_s
    end
    out
  end

  def getLength : Int
    File.read_lines(HISTORY_PATH).size
  end

  def getPosition : Int
    @@position
  end

  def resetPosition
    @@position = -1
  end

  def saveLine(line : String)
    @@savedLine = line
  end

  def loadLine : String
    @@savedLine
  end

  def clearSavedLine
    @@savedLine = ""
  end
end
