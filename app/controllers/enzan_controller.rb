class EnzanController < ApplicationController

  require 'enzan'

  @@enzan = Enzan.new

  def index
#    @bookinfo = {}
#    File.open("/home/masui/hondana2/enzan/marshal.bookinfo"){ |f|
#      @bookinfo = Marshal.load(f)
#    }
  end

  def calculate
    # @enzan = Enzan.new
    (cmd,str) = params[:cmd].split(/&/)

#    File.delete("/home/masui/hondana2/enzan/tmp.html")
#    File.rename("/home/masui/hondana2/enzan/recent.html","/home/masui/hondana2/enzan/tmp.html")
#    File.open("/home/masui/hondana2/enzan/recent.html","w"){ |f|
#      f.puts "<li>#{str}"
#      File.open("/home/masui/hondana2/enzan/tmp.html"){ |old|
#        old.each { |line|
#          f.print line
#          break if $. > 9
#        }
#      }
#    }

    @res = eval(cmd).out # .split(/[\r\n]/).join("\t")

    #@res = cmd
  end

end
