# -*- coding: utf-8 -*-
#
# 本棚books には、本棚名をキーとする連想配列に登録書籍リストが入っている。
#
# しかし本棚と本は対称のはずだから、メソッドなどは同じものが用意されてなければならないと思う。
#
#             本1   本2   本3   本4   本5   本6   本7   本8
#   Aの本棚    1                       1     1
#   Bの本棚                      1     1     1     1     
#   Cの本棚          1     1           1                 1
#

require 'digest/md5'
require 'json/objects'

$KCODE = 'UTF8'

class Enzan
  # @@bookinfo[ISBN] = { 'authors' => '増井', 'title' => 'Perl書法' }
  # @@shelf_books['増井'] = ['4123456789', '5123456789]

  @@bookinfo = nil
  @@shelf_books = nil
  @@book_shelves = nil
  @@books = nil
  @@shelves = nil
  @@initialized = false

  def initialize(rooturl="http://hondana.org", rootdir="/Users/masui/hondana2")
    # #{rootdir}/enzan の下にmarshal.bookinfoとmarshal.shelfbooksというMarshalファイルがある
    # その下の data/ に保存データを置く
    @@rooturl = rooturl
    @@rootdir = rootdir
    if !@@initialized then
      @@initialized = true
      File.open("#{@@rootdir}/enzan/marshal.bookinfo"){ |f|
        @@bookinfo = Marshal.load(f)
        # @@bookinfo['0123456789'] = { title:'タイトル', authors:'著者', isbn:'1234567890' }
      }
      File.open("#{@@rootdir}/enzan/marshal.shelfbooks"){ |f|
        @@shelf_books = Marshal.load(f)
	# @@shelf_books['増井'] = ['0123456789', '1234567890', ...]
      }
      # データ不整合チェック - 本来必要ないはずなのだが。
      @@shelf_books.each { |shelf,books|
        delbooks = []
        books.each { |book|
          if @@bookinfo[book].nil? then
            delbooks << book
          end
        }
        delbooks.each { |book|
          books.delete(book)
        }
      }
    
      # 本に対応する本棚リスト作成
      @@book_shelves = {}
      @@shelf_books.each { |shelf,books|
        books.each { |book|
          @@book_shelves[book] = [] if @@book_shelves[book] == nil
          @@book_shelves[book].push(shelf)
        }
      }
    
      @@books = @@book_shelves.keys
      @@shelves = @@shelf_books.keys
    end
  end

  def Enzan.rootdir
    @@rootdir
  end

  def Enzan.rooturl
    @@rooturl
  end

  def Enzan.bookinfo(isbn=nil)
    if isbn.nil? then
      @@bookinfo
    else
      @@bookinfo[isbn]
    end
  end

  def Enzan.books(shelf=nil)
    res = @@shelf_books[shelf]
    res = [] if res.nil?
    res
  end

  def Enzan.collect_shelves
    @@shelf_books.collect { |shelf,books|
      yield shelf,books
    }
  end

  def Enzan.shelves(book=nil)
    res = @@book_shelves[book]
    res = [] if res.nil?
    res
  end

  def Enzan.collect_books
    @@book_shelves.collect { |book,shelves|
      yield book,shelves
    }
  end
end

class EnzanData
  def initialize(*args)
    @data = {}
  end
  
  def list
    @data.keys.sort { |data1,data2|
      @data[data2] <=> @data[data1]
    }
  end
  
  def [](arg)
    if arg.class == Fixnum then
      list[arg]
    else
      self.class.new(*list[arg])
    end
  end
  
  def each
    list.each { |data|
      yield data
    }
  end
  
  def collect # added 2011/4/4
    list.collect { |data|
      yield data
    }
  end
  
  def count(name)
    @data[name].to_i
  end
  
  def major(thres=1)
    @data.each { |name,count|
      if count < thres then
        @data.delete(name)
      end
    }
    self
  end
  
  def remove(data)
    data.each { |d|
      @data.delete(d)
    }
    self
  end
  
  def add(newdata)
    if newdata.class == self.class then
      newdata.each { |name|
        @date[name] = @data[name].to_i + newdata.count(name)
      }
    else
      newdata.each { |name|
        @data[name] = @data[name].to_i + 1
      }
    end
    self
  end
  
  def save(name)
    hash = Digest::MD5.new.hexdigest(name).to_s
    File.open("#{Enzan.rootdir}/enzan/data/#{hash}","w"){ |f|
      f.print Marshal.dump(self)
    }
    self
  end
  
  def books
    self
  end
  
  def shelves
    self
  end
  
#  def similar(n)
#    Data.new
#  end
  
  def similarshelves(n)
    similar(n)
  end
  
  def similarbooks(n)
    similar(n)
  end
  
  def out(n=20)
    #list[0...n].collect { |data|
    #  "#{data}"
    #}.join("\n")

    list[0...n].to_json
  end

  def intersection(s)
    data = {}
    s.each { |key,val|
      if @data[key] then
        data[key] = @data[key]
      end
    }
    @data = data
    self
  end
end

class Shelves < EnzanData
  def initialize(*args)
    # Shelves.new('増井','4912345678','4923456789')
    @data = {}
    args.each { |arg|
      if arg =~ /^\d{9}[\dX]/ then
        isbn = arg
        Enzan.shelves(isbn).each { |shelfname|
          @data[shelfname] = 1
        }
      else
        shelfname = arg
        @data[shelfname] = 1
      end
    }
  end
  
  def books
    b = Books.new
    @data.keys.each { |shelf|
      b.add(Enzan.books(shelf))
    }
    b
  end
  
  # この本棚リストに「似た」本を捜す
  def similar(n=20)
    set1 = Set.new(@data.keys)
    similarlist = Enzan.collect_books { |book,shelves|
      set2 = Set.new(shelves)
      [book, set1.intersection(set2).length, set2.length]
    }.collect { |v|
      val = Float(v[1]) * 2.0 /Float(v[2]+set1.length)
      val = 0.0 if val.nan?
      [v[0], val, v[1]]
    }.sort { |a,b|
      b[1] <=> a[1]
    }.collect { |v|
      v[0]
    }[0...n]
    Books.new(*similarlist)
  end

  def similarbooks(n=20)
    similar(n)
  end

  def similarshelves(n=20)
    books.similarshelves(n)
  end

  def dump(n=20)
    list[0...n].each { |shelf|
      puts "#{@data[shelf]} #{shelf}"
    }
    self
  end

  def out(n=20)
    #list[0...n].collect { |shelf|
    #  "#{@data[shelf]} <a href='#{Enzan.rooturl}/#{shelf}/'>#{shelf}</a> (#{Enzan.books(shelf).length}冊)"
    #}.join("\n")
    list[0...n].collect { |shelf|
      data = {}
      data['weight'] = @data[shelf]
      data['name'] = shelf
      data['length'] = Enzan.books(shelf).length
      data
    }.to_json
  end
end

class Books < EnzanData
  require 'set'
  include Enumerable

  def initialize(*args)
    # Books.new('街角','4912345678','4923456789')
    @data = {}
    args.each { |arg|
      if arg =~ /^\d{9}[\dX]/ then
        isbn = arg
        @data[isbn] = 1
      else
        arg.gsub!(/\(/,'\\(') # 他にもエスケープ必要な文字があるだろうが...
        arg.gsub!(/\)/,'\\)')
        matcher = /#{arg}/i
        Enzan.bookinfo.each { |isbn,bookinfo|
          # if bookinfo['authors'].index(arg) || bookinfo['title'].index(arg) then
          if matcher.match(bookinfo['authors']) || matcher.match(bookinfo['title']) then
            @data[isbn] = 1
          end
        }
      end
    }
  end

  def shelves
    s = Shelves.new
    @data.keys.each { |book|
      s.add(Enzan.shelves(book))
    }
    s
  end

  # この本リストに「似た」本棚を捜す
  def similar(n=20)
    set1 = Set.new(@data.keys)
    similarlist = Enzan.collect_shelves { |shelfname,books|
      set2 = Set.new(books)
      [shelfname, set1.intersection(set2).length, set2.length]
    }.collect { |v|
      val = Float(v[1]) * 2.0 /Float(v[2]+set1.length)
      val = 0.0 if val.nan?
      [v[0], val,  v[1]]
    }.sort { |a,b|
      b[1] <=> a[1]
    }.collect { |v|
      v[0]
    }[0...n]
    Shelves.new(*similarlist)
  end

  def similarshelves(n=20)
    similar(n)
  end

  def similarbooks(n=20)
    shelves.similarbooks(n)
  end

  def dump(n=20)
    list[0...n].each { |isbn|
      puts "#{@data[isbn]} #{isbn} #{Enzan.bookinfo(isbn)['title']} (#{Enzan.bookinfo(isbn)['authors']})"
    }
    self
  end

  def out(n=20)
#    list[0...n].collect { |isbn|
#      shelf = Enzan.shelves(isbn)[0]
#      title = Enzan.bookinfo(isbn)['title']
#      "#{@data[isbn]} <a href='#{Enzan.rooturl}/#{shelf}/#{isbn}.html'>#{isbn}</a> <span onmousedown='bookbutton(\"#{isbn}\",\"#{title}\")'>#{title}</span> (#{Enzan.bookinfo(isbn)['authors']})"
#    }.join("\n")
    list[0...n].collect { |isbn|
      data = {}
      data['weight'] = @data[isbn]
      data['title'] = title = Enzan.bookinfo(isbn)['title']
      data['authors'] = title = Enzan.bookinfo(isbn)['authors']
      data['isbn'] = isbn
      data['shelves'] = Enzan.shelves(isbn) # [0]
      data
    }.to_json
  end

  def save(name)
    hash = Digest::MD5.new.hexdigest(name).to_s
    File.open("#{Enzan.rootdir}/enzan/data/#{hash}","w"){ |f|
      f.print Marshal.dump(self)
    }
    self
  end
end

class String
  def books
    Books.new(self)
  end

  def shelves
    Shelves.new(self)
  end
end

class Array
  def books
    Books.new(*self)
  end

  def shelves
    Shelves.new(*self)
  end
end

def data(name)
  hash = Digest::MD5.new.hexdigest(name).to_s
  file = "#{Enzan.rootdir}/enzan/data/#{hash}"
  if File.exist?(file) then
    Marshal.load(File.open("#{Enzan.rootdir}/enzan/data/#{hash}"))
  else
    EnzanData.new
  end
end

if __FILE__ == $0
  Enzan.new('http://hondana.org','/Users/masui/hondana')
  # puts "増井".shelves.similarshelves.out
  puts "yuco".shelves.books.out
end
