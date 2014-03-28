# -*- encoding: utf-8 -*-
# -*- ruby -*-
#

require 'ffi'

BOOK=1; SHELF=2
SEARCH=0; ADD=1; SUB=2;  SIMILAR=3

class Enzan
  extend FFI::Library
  ffi_lib "libenzan.so"

  class Freq < FFI::Struct
    layout(
           :index, :int,
           :freq, :int
           )
  end

  attach_function :calc, [:int, :int, :int, :pointer, :pointer], :pointer # Cの演算関数


  @@initialized = false

  def initialize(rootdir="/Users/masui/Hondana")
    # #{rootdir}/enzan の下にmarshal.bookinfoとmarshal.shelfbooksというMarshalファイルがある
    @@rootdir = rootdir
    if !@@initialized then
      @@initialized = true
      File.open("#{@@rootdir}/enzan/marshal.bookinfo"){ |f|
        data = Marshal.load(f)
        # data['0123456789'] = { title:'タイトル', authors:'著者', isbn:'1234567890' }
        @@bookinfo = {}
        data.each { |isbn,info|
          bookdata = {}
          info.each { |key,val|
            bookdata[key] = val.to_s.dup.force_encoding("UTF-8")
          }
          @@bookinfo[isbn] = bookdata
        }
      }
      File.open("#{@@rootdir}/enzan/marshal.shelfbooks"){ |f|
        data = Marshal.load(f)
	# data['増井'] = ['0123456789', '1234567890', ...]
        @@shelf_books = {}
        data.each { |shelf,isbns|
          shelfdata = {}
          @@shelf_books[shelf.dup.force_encoding("UTF-8")] = isbns
        }
      }
      # 何故かbookinfoが空のことがあるので、そういうエントリを除く
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

      #
      # 本棚名、ISBNをソートした配列とその逆を計算する連想配列
      #
      @@ind_isbn = @@book_shelves.keys.sort
      @@isbn_ind = {}
      @@ind_isbn.each_with_index { |isbn,ind|
        @@isbn_ind[isbn] = ind
      }
      @@ind_shelfname = @@shelf_books.keys.sort
      @@shelfname_ind = {}
      @@ind_shelfname.each_with_index { |shelfname,ind|
        @@shelfname_ind[shelfname] = ind
      }
      puts "--------------Init end"
    end
  end

  def Enzan.ind_shelfname(ind)
    @@ind_shelfname[ind]
  end

  def Enzan.ind_isbn(ind)
    @@ind_isbn[ind]
  end

  def Enzan.shelfname_ind(shelfname)
    @@shelfname_ind[shelfname]
  end

  def Enzan.isbn_ind(isbn)
    @@isbn_ind[isbn]
  end

  def Enzan.rootdir
    @@rootdir
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
    res.nil? ? [] : res
  end

  def Enzan.collect_books
    @@book_shelves.collect { |book,shelves|
      yield book,shelves
    }
  end

  def Enzan.shelves(book=nil)
    res = @@book_shelves[book]
    res.nil? ? [] : res
  end

  def Enzan.collect_shelves
    @@shelf_books.collect { |shelf,books|
      yield shelf,books
    }
  end
end

class EnzanData
  def initialize(*args)
    Enzan.new
    @data = {}
  end

  def data
    puts "______________"
    @data
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

  #
  # FFIでC関数を読んだり返り値を読んだりするもの。
  # 仕様がよくわかっていないのでこれで良いのか不明だがとりあえず動く
  #
  def rbdata2cdata(type)
    p = FFI::MemoryPointer.new(Enzan::Freq, @data.length+1)
    i = 0
    @data.keys.sort.each { |key|
      val = @data[key]
      f = Enzan::Freq.new(p[i])
      f[:index] = (type == BOOK ? Enzan.isbn_ind(key) : Enzan.shelfname_ind(key))
      # ind(key)
      f[:freq] = val
      i += 1
    }
    f = Enzan::Freq.new(p[i])
    f[:index] = -1
    f[:freq] = 0
    p
  end

  def cdata2rbdata(p,type)
    i = 0
    size = Enzan::Freq.size
    data = {}
    while true do
      f = Enzan::Freq.new p+size*i
      break if f[:index] < 0
      ind = f[:index]
      n = (type == BOOK ? Enzan.ind_isbn(ind) : Enzan.ind_shelfname(ind))
      puts "#{ind} => #{n}"
      data[n] = f[:freq]
      # data[name(f[:index])] = f[:freq]
      i += 1
    end
    data
  end
end

class Shelves < EnzanData
  def initialize(*args)
    # Shelves.new('増井','4912345678','4923456789')
    # Shelves.new({'増井' => 2, '4912345678' => 3})
    super(*args)
    if args[0].class == Hash then
      @data = args[0]
    else
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
  end

  # 本棚(リスト)に入っている本のリストを得る
  def books
    b = Books.new
    @data.keys.each { |shelf|
      b.add(Enzan.books(shelf))
    }
    b
  end

  # 本棚(リスト)に近い本棚を得る
  def similarshelves
    a = rbdata2cdata(SHELF)
    res = Enzan.calc(SIMILAR,SHELF,SHELF,a,nil)
    shelves = cdata2rbdata(res,SHELF)
    Shelves.new(shelves)
  end

  # 本棚(リスト)に近い本を得る
  def similarbooks
    a = rbdata2cdata(SHELF)
    res = Enzan.calc(SIMILAR,SHELF,BOOK,a,nil)
    books = cdata2rbdata(res,BOOK)
    Books.new(books)
  end
end

class Books < EnzanData
  include Enumerable

  def initialize(*args)
    # Books.new('街角','4912345678','4923456789')
    super(*args)
    if args[0].class == Hash then
      @data = args[0]
    else
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
  end

end

# # s = Shelves.new('増井','4569534074')
s = Shelves.new('増井研')
ss = s.similarshelves
p ss
exit

# books = Books.new('街角')

# s = Shelves.new('増井','suchi')
s = Shelves.new('yuco')
books = s.similarbooks
# books = s.books
p books
p books.class
p books.data.class
puts "-----"
books.data.each { |isbn,freq|
  puts Enzan.bookinfo[isbn]
}

# s = Shelves.new('4569534074')
# p s
exit

# 
# 
# data = Marshal.load(File.read('marshal.shelfbooks'))
# 
# shelfnames = data.keys.collect { |shelfname|
#   shelfname.dup.force_encoding("UTF-8")
# }.sort
# 
# shelf_ind = {}
# shelfnames.each_with_index { |shelfname,ind|
#   shelf_ind[shelfname] = ind
# }
# 
# isbn_shelves = {}
# all_isbns = {}
# data.each { |shelfname,isbns|
#   s = shelfname.dup
#   s.force_encoding("UTF-8")
#   isbns.each { |isbn|
#     isbn_shelves[isbn] = {} unless isbn_shelves[isbn]
#     isbn_shelves[isbn][shelf_ind[s]] = 1
#     all_isbns[isbn] = 1
#   }
# }
# isbn_shelves.each { |isbn,shelves|
#   isbn_shelves[isbn] = shelves.keys.sort
# }
# 
# isbns = all_isbns.keys.sort
# isbn_ind = {}
# isbns.each_with_index { |isbn,ind|
#   isbn_ind[isbn] = ind
# }
# 
# 
# 
# 
# 
# 
# #########################################################
# require 'ffi'
# 
# BOOK=1
# SHELF=2
# SEARCH=0
# ADD=1
# SUB=2
# SIMILAR=3
# 
# module Enzan
#   extend FFI::Library
#   ffi_lib "libenzan.so"
# 
#   class Freq < FFI::Struct
#     layout(
#            :index, :int,
#            :freq, :int
#            )
#   end
#   
#   attach_function :shelves, [:int], :pointer
#   attach_function :calc, [:int, :int, :int, :pointer, :pointer], :pointer
#   attach_function :test, [:pointer], :int
# end
# 
# a = FFI::MemoryPointer.new(Enzan::Freq, 5)
# puts a
# b = Enzan::Freq.new(a[0])
# b[:index] = 10
# b[:freq] = 20
# c = Enzan::Freq.new(a[1])
# c[:index] = 100
# c[:freq] = 200
# d = Enzan::Freq.new(a[2])
# d[:index] = -1
# d[:freq] = 1111
# 
# Enzan.test(a)
# exit
# 
# p1 = Enzan.shelves(shelf_ind['suchi'])
# p2 = Enzan.shelves(shelf_ind['yuco'])
# p = Enzan.calc(ADD,SHELF,SHELF,p1,p2)
# 
# #puts p[0].read_int
# #puts p[4].read_int
# #puts p[8].read_int
# 
# suchibooks = Enzan.calc(SEARCH,SHELF,BOOK,p1,p1)
# 
# def list_freq(p)
#   i = 0
#   size = Enzan::Freq.size
#   while true do
#     foo = Enzan::Freq.new p+size*i
#     puts foo[:index]
#     puts foo[:freq]
#     break if foo[:index] < 0
#     i += 1
#   end
# end
# 
# list_freq(suchibooks)
# exit
# 
# foo = Enzan::Freq.new suchibooks[8]
# p Enzan::Freq.size
# p foo.class
# p foo[:index].class
# p foo[:index]
# p foo[:freq].class
# p foo[:freq]
# exit
# 
# foo = Enzan::Freq.new suchibooks[8]
# p Enzan::Freq.size
# p foo.class
# p foo[:index].class
# p foo[:index]
# p foo[:freq].class
# p foo[:freq]
# exit



i = 0
ind = suchibooks[i*8].read_int
while ind >= 0 do
  puts ind
  puts isbns[ind]
  i += 1
  ind = suchibooks[i*8].read_int
end

exit

similarshelf = Enzan.calc(SIMILAR,BOOK,SHELF,suchibooks,suchibooks)
i = 0
ind = similarshelf[i*8].read_int
while ind >= 0 do
  puts ind
  puts shelfnames[ind]
  i += 1
  ind = similarshelf[i*8].read_int
end
