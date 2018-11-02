class Historian

  HISTORY_PATH = "/home/#{Process.user}/.hist.love"
  @@position = -1
  @@savedLine = ""

  def log(message : String)
    if message != ""
      histfile = File.new(HISTORY_PATH, "a")
      histfile.puts(message)
      histfile.close
    end
  end

  #def getEntryUp : String
  #  histLength = File.read_lines(HISTORY_PATH).size - 1
  #  histLog = File.read_lines(HISTORY_PATH).reverse
  #  @@position += 1
  #  if @@position > histLength
  #    @@position = histLength
  #  end
  #  out = histLog[@@position].to_s
  #  out
  #end

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
    unless @@savedLine == ""                                    #Jeśli mam coś zapisane
      while true
        @@position -= 1                                         #Pozycja się zmniejsza
        if @@position < 0                                       #Jeśli jest < 0
          @@position = -1                                       #Upewniam się że zostanie na -1
          out = @@savedLine                                     #Upewniam się że w prompcie będę miał to co zapisałem
          break                                                 #I wychodzę z pętli
        end
        out = histLog[@@position].to_s                          #Inaczej biorę to co mam na danej pozycji
        break if out[0..@@savedLine.size - 1] == @@savedLine    #Sprawdzam czy pasuje do tego co szukam
      end
      out                                                       #Returnuję wpis
    else                                                        #Inaczej
      while true
        @@position -= 1                                         #Pozycja się zmniejsza
        if @@position < 0                                       #Jeśli jest < 0
          @@position = -1                                       #Upewniam się że zostanie na -1
          out = ""                                              #Upewniam się że prompt będzie pusty
          break                                                 #Wychodzę z pętli
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
