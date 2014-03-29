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

  # 初期化にかなり時間がかかるのをなんとかしたいものだが...
  def initialize(rootdir="/Users/masui/Hondana")
    # #{rootdir}/enzan の下にmarshal.bookinfoとmarshal.shelfbooksというMarshalファイルがある
    if !@@initialized then
      @@initialized = true
      @@rootdir = rootdir
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
      # bookinfoが空のエントリを除く
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
    end
  end

  # 本棚番号から本棚名を得る
  def Enzan.ind_shelfname(ind)
    @@ind_shelfname[ind]
  end

  # 本番号からISBNを得る
  def Enzan.ind_isbn(ind)
    @@ind_isbn[ind]
  end

  # 本棚名から本棚番号を得る
  def Enzan.shelfname_ind(shelfname)
    @@shelfname_ind[shelfname]
  end

  # ISBNから本番号を得る
  def Enzan.isbn_ind(isbn)
    @@isbn_ind[isbn]
  end

  def Enzan.bookinfo(isbn=nil)
    if isbn.nil? then
      @@bookinfo
    else
      @@bookinfo[isbn]
    end
  end

  def Enzan.shelf_books(shelf)
    @@shelf_books[shelf].to_a
  end

  def Enzan.book_shelves(isbn)
    @@book_shelves[isbn].to_a # nil => []
  end
end

class EnzanData
  include Enumerable
  def initialize(*args)
    Enzan.new
    @data = {}
  end

  def data
    @data
  end

  def each
    @data.each { |key,val|
      yield key, val
    }
  end

  def length
    @data.length
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
      # puts "#{ind} => #{n}"
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
      # 第1引数がHashの場合はデータを直接わたす
      @data = args[0]
    else
      @data = {}
      args.each { |arg|
        if arg =~ /^\d{9}[\dX]/ then
          isbn = arg
          Enzan.book_shelves(isbn).each { |shelfname|
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
      b.add(Enzan.shelf_books(shelf))
    }
    b
  end

  # 本棚(リスト)に近い本棚を得る
  def similarshelves
    a = rbdata2cdata(SHELF)                     # @dataを2次元配列に変換
    res = Enzan.calc(SIMILAR,SHELF,SHELF,a,nil) # C関数呼び出し
    shelves = cdata2rbdata(res,SHELF)           # 2次元配列をハッシュに戻す
    Shelves.new(shelves)
  end

  # 本棚(リスト)に近い本を得る
  def similarbooks
    a = rbdata2cdata(SHELF)
    res = Enzan.calc(SIMILAR,SHELF,BOOK,a,nil)
    books = cdata2rbdata(res,BOOK)
    Books.new(books)
  end

  def dump
    @data.each { |shelfname,freq|
      puts "#{shelfname} => #{freq}"
    }
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

  # 本(リスト)にが登録されている本棚のリストを得る
  def shelves
    s = Shelves.new
    @data.keys.each { |book|
      s.add(Enzan.book_shelves(book))
    }
    s
  end

  # 本(リスト)に近い本を得る
  def similarbooks
    a = rbdata2cdata(BOOK)                     # @dataを2次元配列に変換
    res = Enzan.calc(SIMILAR,BOOK,BOOK,a,nil)  # C関数呼び出し
    books = cdata2rbdata(res,BOOK)             # 2次元配列をハッシュに戻す
    Books.new(books)
  end

  # 本(リスト)に近い本棚を得る
  def similarshelves
    a = rbdata2cdata(BOOK)
    res = Enzan.calc(SIMILAR,BOOK,SHELF,a,nil)
    shelves = cdata2rbdata(res,SHELF)
    Shelves.new(shelves)
  end

  def dump
    @data.each { |isbn,freq|
      info = Enzan.bookinfo(isbn)
      puts "#{isbn} => #{freq}, #{info['title']} / #{info['authors']}"
    }
  end
end

#
# テスト
#
if __FILE__ == $0 then
  require 'test/unit'

  class EnzanTest < Test::Unit::TestCase
    def setup
      Enzan.new
    end
    
    def teardown
    end

    def test_enzan1
      (0..100).each { |ind|
        shelfname = Enzan.ind_shelfname(ind)
        assert ind == Enzan.shelfname_ind(shelfname)
      }
      (0..100).each { |ind|
        isbn = Enzan.ind_isbn(ind)
        assert isbn.length == 10
        assert ind == Enzan.isbn_ind(isbn)
      }
    end

    def test_shelf_class
      s = Shelves.new('増井')
      assert s.class == Shelves
      assert s.data.class == Hash
      assert s.data.length > 0
    end
    
    def test_shelf_books
      s = Shelves.new('増井')
      b = s.books
      assert b.class == Books
      assert b.length > 3000
      b.each { |key,val|
        assert key.length == 10
        assert val.to_i > 0
      }
    end

    def test_shelf_books2
      # 「増井の本棚」に「ウェブ進化論」はあるか?
      s = Shelves.new('増井')
      b = s.books
      found = nil
      b.each { |key,val|
        found = true if key == '4480062858' # ウェブ進化論
      }
      assert found

      # 「情報視覚化の本棚」に「ウェブ進化論」はあるか?
      s = Shelves.new('情報視覚化')
      b = s.books
      found = nil
      b.each { |key,val|
        found = true if key == '4480062858' # ウェブ進化論
      }
      assert !found
    end

    def test_shelf_similar
      s = Shelves.new('増井')
      ss = s.similarshelves
      assert ss.class == Shelves
      assert ss.length > 0
      found = false
      ss.each { |shelf,freq|
        found = true if shelf == '増井研'
      }
      assert found
    end

    def test_book_class
      b = Books.new('4480062858') # ウェブ進化論
      #b = Books.new('4106100037') # バカの壁
      assert b.class == Books
      assert b.data.class == Hash
      assert b.data.length > 0
    end
    
    def test_book_shelves
      b = Books.new('4480062858') # ウェブ進化論
      #b = Books.new('4106100037') # バカの壁
      s = b.shelves
      assert s.class == Shelves
      assert s.length > 30
      s.each { |key,val|
        assert key.class == String
        assert key.length > 0
        assert val.to_i > 0
      }
    end

    def test_book_shelves2
      # 「ウェブ進化論」の本棚リストに「増井の本棚」はあるか?
      b = Books.new('4480062858') # ウェブ進化論
      s = b.shelves
      found = false
      s.each { |key,val|
        found = true if key == '増井'
      }
      assert found

      # 「ウェブ進化論」の本棚リストに「情報視覚化の本棚」はあるか?
      b = Books.new('4480062858') # ウェブ進化論
      s = b.shelves
      found = false
      s.each { |key,val|
        found = true if key == '情報視覚化'
      }
      assert !found
    end

    def test_book_similar
      b = Books.new('4480062858') # ウェブ進化論
      bb = b.similarbooks
      assert bb.class == Books
      assert bb.length > 0

      found = false
      bb.each { |isbn,freq|
        found = true if Enzan.bookinfo(isbn)['title'] =~ /「へんな会社」のつくり方/
      }
      assert found
    end

    def test_bookinfo
      info = Enzan.bookinfo('4480062858') # ウェブ進化論
      assert info['authors'] =~ /梅田/
    end

    def test_shelf_each
      s = Shelves.new('増井','suchi')
      s.each { |shelf,freq|
        assert shelf == '増井' || shelf == 'suchi'
        assert freq == 1
      }
      s.books.each { |isbn,freq|
        assert isbn.length == 10
        assert freq == 1 || freq == 2
      }
    end
  end
end
