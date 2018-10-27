class Historian

  HISTORY_PATH = "/home/#{Process.user}/.hist.love"
  @@position = -1

  def log(message : String)
    if message != ""
      histfile = File.new(HISTORY_PATH, "a")
      histfile.puts(message)
      histfile.close
    end
  end

  def getEntryUp : String
    histLength = File.read_lines(HISTORY_PATH).size - 1
    histLog = File.read_lines(HISTORY_PATH).reverse
    @@position += 1
    if @@position > histLength
      @@position = histLength
    end
    out = histLog[@@position].to_s
    out
  end

  def getEntryDown : String
    @@position -= 1
    if @@position < 0
      @@position = -1
    end

    if @@position == -1
      out = ""
    else
      histLog = File.read_lines(HISTORY_PATH).reverse
      out = histLog[@@position].to_s
    end
    out
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
end
