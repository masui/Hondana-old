class IqauthController < ApplicationController
  require 'digest/md5'
  require 'pathname'
  require 'cgi'

  def hash(s)
    begin
      Digest::MD5.new.hexdigest(s).to_s  # thin
    rescue
      Digest::MD5.new(s)  #lighttpd??
    end
  end

  def filename(id,type)
    #dir = (Pathname.new($0).parent.parent+"db/iqauth").to_s # script/serverで起動したとき
    #dir = "db/iqauth" # thin で起動したとき
    dir = "#{RAILS_ROOT}/db/iqauth"
    file = hash(id)
    "#{dir}/#{file}.#{type}"
  end

  def value(id,type)
    v = nil
    begin
      File.open(filename(id,type)){ |f|
        v = f.readlines.join
      }
    rescue
    end
    v
  end
  
  def create
    @id = params[:id]
  end
  
  def getdata
    @id = params[:id]

    password = value(@id,'password')
    password ||= ''
    password.chomp!

    query = value(@id,'query')
    query ||= "[]"

    # JSON形式でハッシュと問題を返す
    @result = "[\"#{hash(password)}\", #{query}]"
  end

  def register
    id = params[:id]
    password = params[:password]
    newpassword = params[:newpassword]
    query = params[:query]

    curpassword = value(id,'password')
    curpassword ||= ''
    curpassword.chomp!

    @result = '0'
    if curpassword == '' || curpassword == password then
      @result = '1'
      File.open(filename(id,'id'),"w"){ |f|
        f.puts id
      }
      if newpassword != '' then
        File.open(filename(id,'password'),"w"){ |f|
          f.puts newpassword
        }
      end
      if query != '' then
        File.open(filename(id,'query'),"w"){ |f|
          f.puts CGI.unescape(query)
        }
      end
    end
  end

end
