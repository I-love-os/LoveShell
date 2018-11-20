require "http/client"
require "file_utils"

class Helper
  WIKI_DIR = "#{ENV["HOME"]}/.config/Love/wiki/"

  unless File.directory?(WIKI_DIR)
    FileUtils.mkdir(WIKI_DIR)
  end

  def getHelp(topic : String)
    failed = false
    article_path = "#{WIKI_DIR}/#{topic}.txt"
    topic = topic.downcase
    begin
      response = HTTP::Client.get "https://raw.githubusercontent.com/wiki/I-love-os/LoveShell/#{topic}.md"
    rescue
      failed = true
    end
    if !response.nil? && response.status_code == 200
      unless File.exists?(article_path)
        puts "Creating a local version of the help article.\n\n"
        File.write(article_path, response.body)
        puts File.read(article_path)
      else
        if response.body.lines[0].to_s != File.read(article_path).lines[0].to_s
          puts "Updating the help article.\n\n"
          File.write(article_path, response.body)
        end
        puts File.read(article_path)
      end
    else
      puts "Couldn't update the article. Opening the local version.\n\n"
      unless File.exists?(article_path)
        puts "No local version found."
      else
        puts File.read(article_path)
      end
    end
  end

end
