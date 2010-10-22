class ShelfController < ApplicationController
#  caches_page :show_recent_image, :edit
#  caches_page :show_score_detail

  # require '/home/masui/hondana/lib/myamazon' # ?????
#  require 'myamazon'
  require 'amazon2009'
  require 'iqauth'
  require 'atom'
  require 'kconv'

  def index
    list
    render :action => 'list'
  end

#  def list
#    @newentries = Entry.find(:all, :order => "modtime DESC", :limit => 10)
#    @top20 = Shelf.find(:all, :order => "modtime DESC", :limit => 20)
#    @rand10 = Shelf.find(:all, :order => "random()", :limit => 10)
#    @shelf_pages, @shelves = paginate :shelf, :per_page => 10
#  end

  # hondana.org/abc みたいな場合 shelf は'abc'
  def show
    getshelf
    if @shelf.nil? then
      #redirect_to :controller => 'shelf', :action => 'list'
      redirect_to :controller => 'bookshelf', :action => 'list'
      return
    end
    case @shelf.listtype
    when 'text'
      case @shelf.sorttype
      when 'score'
        show_score_text
        render :action => 'show_score_text'
      else
        show_recent_text
        render :action => 'show_recent_text'
      end
    when 'detail'
      case @shelf.sorttype
      when 'score'
        show_score_detail
        render :action => 'show_score_detail'
      else
        show_recent_detail
        render :action => 'show_recent_detail'
      end
    else
      case @shelf.sorttype
      when 'score'
        show_score_image
        render :action => 'show_score_image'
      else
        show_recent_image
        render :action => 'show_recent_image'
      end
    end
  end

  def show_recent(type, per_page)
    getshelf
    @shelf.listtype = type
    @shelf.sorttype = 'recent'
    @shelf.save
    @entrylist = Entry.paginate(:page => params[:page], :per_page => per_page,
       :conditions => ["shelf_id = ?", @shelf.id], :order => "modtime DESC")
  end

  def show_recent_image
    show_recent('image',60)
  end

  def show_recent_text
    show_recent('text',200)
  end

  def show_recent_detail
    show_recent('detail',20)
  end

  def show_score(type, per_page)
    getshelf
    @shelf.listtype = type
    @shelf.save
    @shelf.sorttype = 'score'
    @entrylist = Entry.paginate(:page => params[:page], :per_page => per_page,
      :conditions => ["shelf_id = ?", @shelf.id], :order => "score DESC")
  end

  def show_score_image
    show_score('image',60)
  end

  def show_score_text
    show_score('text',200)
  end

  def show_score_detail
    show_score('detail',20)
  end

  def edit
    getall
    if @shelf.nil? then
      redirect_to :controller => 'shelf', :action => 'list'
    elsif @entry.nil? then
#      @isbn = params[:isbn]
      newbooks
      render :action => 'newbooks'
    end
    File.open("/tmp/log","w"){ |f|
      f.puts @book.title
    }
  end

  def write
    getall
    newentry = params[:entry][:score].to_s == '' &&
               params[:entry][:categories].to_s == '' &&
               params[:entry][:comment].to_s == ''
    clicktime = @entry.clicktime
    comment = params[:entry][:comment].to_s
    spamp = false
    if !newentry && clicktime && Time.now - clicktime > 600 then
      spamp = true
    end
    if comment =~ /href=/i then
      spamp = true
    end

    if spamp then
      redirect_to :action => 'edit', :isbn => @book.isbn
    else
      @entry.score = params[:entry][:score]
      @entry.categories = params[:entry][:categories].sub(/\s*$/,'')
      @entry.comment = params[:entry][:comment]
      @entry.modtime = Time.now
      @entry.clicktime = Time.now
      @entry.save
      @shelf.modtime = Time.now
      @shelf.save

     File.open("#{RAILS_ROOT}/log/write.log","a"){ |f|
       f.puts "------------------"
       f.puts @shelf.name
       f.puts @book.title
       f.puts @book.isbn
       f.puts @entry.comment
     }

      # トップページのキャッシュをexpire
      expire_page :controller => 'bookshelf', :action => 'list'

      # Atomを生成
      write_atom("#{RAILS_ROOT}/public/atom.xml")

      redirect_to :action => 'edit', :isbn => @book.isbn
    end
  end

  def category_text
    getshelf
    categories = {}
    @shelf.entries.each { |entry|
      entry.categories.split(/,\s*/).each { |category|
        categories[category] = 1
      }
    }
    @categories = categories.keys
  end

  def category_image
    category_text
  end

  def category_detail
    getshelf
    @category = params[:category]
  end

  def category_simple
    getshelf
    @category = params[:category]
  end

  def category_bookselect
    getshelf
    @category = params[:category]
  end

  def category_bookset
    getshelf
    @category = params[:category]
    isbns = Set.new
    params.each { |key,val|
      if key =~ /^\d{9}[\dX]$/ then
        isbns.add(key)
      end
    }
    @shelf.entries.each { |entry|
      categories = Set.new(entry.categories.split(/,\s*/))
      if categories.member?(@category) && !isbns.member?(entry.book.isbn) then
        categories.delete(@category)
      elsif !categories.member?(@category) && isbns.member?(entry.book.isbn) then
        categories.add(@category)
      end
      entry.categories = categories.to_a.join(', ')
      entry.save
    }
    redirect_to :action => 'category_bookselect', :category => @category
  end

  def category_rename
    getshelf
    @category = params[:category]
  end

  def category_setname
    getshelf
    @category = params[:category]
    @newcategory = params[:newcategory]
    @shelf.entries.each { |entry|
      categories = Set.new(entry.categories.split(/,\s*/))
      if categories.member?(@category) then
        categories.delete(@category)
        categories.add(@newcategory) if @newcategory != ''
        entry.categories = categories.to_a.join(', ')
        entry.save
      end
    }
    redirect_to :action => (@newcategory == '' ? 'category_text' : 'category_detail'), :category => @newcategory
  end

  def profile_edit
    getshelf
  end

  def profile_write
    getshelf
    description = params[:shelf][:description]
    if description !~ /href=/i then
      @shelf.description = description
      @shelf.url = params[:shelf][:url]
      @shelf.affiliateid = params[:shelf][:affiliateid]
      @shelf.use_iqauth = params[:shelf][:use_iqauth]
      @shelf.save
    end
    redirect_to :action => 'profile_edit'
  end

  def rename
    getshelf
  end


  def setname
    getshelf
    newname = params[:shelf][:name]

#  shelfname = 'タカヒロ'
# # @shelf = Shelf.find(:first, :conditions => ["name = ?", shelfname])
#  @shelf = Shelf.find(:first, :conditions => ["name like ?", "タカヒロ%"])
#  File.open("/tmp/xxxxx","w"){ |f|
#    f.puts @shelf
#  }
#  newname = "takahiroyyy"
# # return

    #return # SPAM taisaku masui
    if newname == '' then
      @newname = @shelf.name + '_deleted000'
      while ! Shelf.find(:first, :conditions => ["name = ?", @newname]).nil? do
        @newname = @newname.succ
      end
    else
      @newname = newname
      if ! Shelf.find(:first, :conditions => ["name = ?", newname]).nil? then
        @newname = @shelf.name
        redirect_to :action => 'rename', :shelfname => @newname, :error => "同じ名前の本棚が存在します"
      end
    end

    @shelf.name = @newname # 本棚名変更!!
    @shelf.modtime = Time.now
    @shelf.save
    if newname == '' then
      redirect_to :controller => 'bookshelf', :action => 'list'
    else
      redirect_to :action => 'show', :shelfname => @newname
    end

#    if newname == '' then
#      # 本棚消去する必要があるが、どうやるかは未定。
#      newname = 
#    end
#    if Shelf.find(:first, :conditions => ["name = ?", newname]).nil? then
#      @shelf.name = newname # 本棚名変更!!
#      @shelf.modtime = Time.now
#      @shelf.save
#    else
#      # 本棚が既に存在する.... エラーをうまく表示すること。
#      # @shelf.errors.add_to_base("同じ名前の本棚が存在します") だとうまくいかない...
#      @newname = @shelf.name
#      redirect_to :action => 'rename', :shelfname => @newname, :error => "同じ名前の本棚が存在します"
#    end
#    redirect_to :action => 'show', :shelfname => @newname
  end

  def newbooks
    getshelf
#    @isbn = params[:isbn]
    params[:isbn] =~ /\d{9}[\dX]/
    @isbn = $&
  end

  def reload
    getshelf
    getbook
    @book = Book.find(:first, :conditions => ["isbn = ?", @isbn])
    if @book.nil? then
        @book = Book.new
    end
    amazon = MyAmazon.new
    @book.isbn = @isbn
    @book.title = amazon.title(@isbn)
    @book.publisher = amazon.publisher(@isbn)
    @book.authors = amazon.authors(@isbn)
    @book.price = 0
    @book.imageurl = amazon.image(@isbn)
    @book.modtime = Time.now
    @book.save
  end

  def add
    getshelf
#    s = params[:isbns][:list]
    s = params[:isbns]
    s.gsub!(/[\r\n]/,' ')
    s.gsub!(/\-/,'')
    @isbns = []

    while s =~ /^(.*)(978\d{10})(.*)$/m do
      s = $1+$3
      @isbns << id2isbn($2)
    end
    
    while s =~ /^(.*)(\d{9}[\dX])(.*)$/m do
      s = $1+$3
      @isbns << $2
    end

    if @isbns.length == 0 then
      redirect_to :action => 'newbooks', :error => "10桁のISBNか13桁のバーコード番号を指定して下さい。"
      return
    end

    @isbns.each { |isbn|
      @book = Book.find(:first, :conditions => ["isbn = ?", isbn])
      if @book.nil? then
        @book = Book.new
        amazon = MyAmazon.new
        @book.isbn = isbn
        @book.title = amazon.title(isbn)
        @book.publisher = amazon.publisher(isbn)
        @book.authors = amazon.authors(isbn)
        @book.price = 0
        @book.imageurl = amazon.image(isbn)
        @book.modtime = Time.now
        @book.save
      end

#      File.open("/tmp/logloglog","a"){ |f|
#        f.puts @book.isbn
#        f.puts @book.title
#        f.puts @book.publisher
#        f.puts @book.authors
#      }
#      @book2 = Book.find(:first, :conditions => ["isbn = ?", isbn])
#      File.open("/tmp/logloglog","a"){ |f|
#        f.puts @book2.isbn
#        f.puts @book2.title
#        f.puts @book2.publisher
#        f.puts @book2.authors
#      }

      @entry = Entry.find(:first, :conditions => ["book_id = ? and shelf_id = ?", @book.id, @shelf.id])
      if @entry.nil? then
        @entry = Entry.new
        @entry.book_id = @book.id
        @entry.shelf_id = @shelf.id
        @entry.modtime = Time.now
        @entry.clicktime = Time.now
        @entry.comment = ''
        @entry.score = ''
        @entry.categories = ''
        @entry.save
      end
    }

    # redirect_to :action => 'show'
    redirect_to :action => 'edit', :isbn => @isbns[0]
  end

  def delete
    getall
  end

  def realdelete
    getall
    # Should allow 'destroy' only when nazonaz-ninsho is available.!!! masui
    @entry.destroy # spam masui !!!!!!!!!!!!!!!
    redirect_to :shelfname => @shelf.name, :action => 'show'
  end

  def datalist
    getshelf

    require 'json/lexer'
    a = []
    @shelf.entries.each { |entry|
      book = entry.book
      d = {}
      d['title'] = book.title
      d['isbn'] = book.isbn
      d['date'] = entry.modtime
      d['publisher'] = book.publisher
      d['authors'] = book.authors
      d['categories'] = entry.categories
      d['score'] = entry.score
      d['comment'] = entry.comment
      a << d
    }
    s = a.to_json
    s.gsub!(/","/,"\",\n  \"")
    s.gsub!(/\},\{/,"\n},\n{")
    s.gsub!(/\{"/,"{\n  \"")
    s.gsub!(/":"/,"\" : \"")
    s.sub!(/\[\{/,"[\n{")
    s.sub!(/\}\]/,"\n}\n]")
    s.gsub!(/</,"&lt;")
    @jsonstr = s
  end

  def help; getshelf; end

  def similar
#    require 'enzan'
    getshelf
#    @shelflist = BookList.new(@shelf.name).similar[0..9].collect { |shelf|
#      Shelf.find(:first, :conditions => ["name = ?", shelf])
#      # shelf
#    }

    #    shelf1 = @shelf
    #    a = @shelf.entries.collect { |entry|
    #      entry.book.isbn
    #    }
    #    set1 = Set.new(a)
    #
    #    @shelflist = Shelf.find(:all, :conditions => ["id < 100"])
    #    ##@shelflist = Shelf.find(:all)
    #
    #    @shelflist = @shelflist.collect { |shelf2|
    #      a = shelf2.entries.collect { |entry|
    #        entry.book.isbn
    #      }
    #      set2 = Set.new(a)
    #      [shelf2, set1.intersection(set2).length, set2.length]
    #    }.find_all { |v|
    #      v[2] != 0 && v[0].name != shelf1.name
    #    }.collect { |v|
    #      [v[0], Float(v[1]) * 2.0 /Float(v[2]+set1.length), v[1]]
    #    }.sort { |a,b|
    #      b[1] <=> a[1]
    #    }
    ##    i = 0
    ##    entries = Entry.find(:all).each { |entry|
    ##      i += 1
    ##    }
    ##    @i = i
  end

  def search
    getshelf
    @q = params[:q]
    @book = Book.find(:first, :conditions => ["authors like ? or title like ?", "%"+@q+"%", "%"+@q+"%"])

    if @book.nil? then
      redirect_to :shelfname => @shelf.name, :action => 'list'
    else
      redirect_to :shelfname => @shelf.name, :action => 'edit', :isbn => @book.isbn
    end
  end

  def clicktime
    getall
    @entry.clicktime = Time.now
    @entry.save
    render :layout => false   # これがあるとclicktime.rhtmlは要らない?
  end

  def cookieset
    getshelf
    cookies[:ShelfDir] = {
      :value => @shelf.name,
      :expires => 5.years.from_now,
      :path => '/',
      :domain => 'hondana.org'
    }
    redirect_to :shelfname => @shelf.name, :action => 'help'
  end

  def cookiereset
    getshelf
    cookies[:ShelfDir] = {
      :value => '',
      :expires => 5.years.from_now,
      :path => '/',
      :domain => 'hondana.org'
    }
    redirect_to :shelfname => @shelf.name, :action => 'help'
  end

  ############################################################################

  private
  def getshelf
    shelfname = params[:shelfname]
    @shelf = Shelf.find(:first, :conditions => ["name = ?", shelfname])
    if @shelf.nil? then # 古いEUCの本棚名を試す
      shelfname = shelfname.gsub(/[A-F][\dA-F][A-F][\dA-F]/){
        [$&].pack('H*')
      }
      shelfname = Kconv.toutf8(shelfname)
      @shelf = Shelf.find(:first, :conditions => ["name = ?", shelfname])
    end
  end

  def getbook
    params[:isbn] =~ /\d{9}[\dX]/
    @isbn = $&
    @book = Book.find(:first, :conditions => ["isbn = ?", @isbn])
#File.open("/tmp/aho","w"){ |f|
#  f.puts @book
#}
  end

  def getentry
    @entry = Entry.find(:first, :conditions => ["book_id = ? and shelf_id = ?", @book.id, @shelf.id])
    #@entry = Entry.find(:first, :conditions => ["book_id = ? and shelf_id = ?", 74219, 1399])
  end

  def getall
    # この順番は大事
    getshelf
    getbook
    getentry
  end

  def add_checksum(isbn)
    v = 0
    (0..8).each { |i|
      v += isbn[i,1].to_i * (i+1)
    }
    v %= 11
    checksum = (v == 10 ? 'X' : v.to_s)
    isbn + checksum
  end

  def id2isbn(id)
    # 書籍のバーコードのISBNは'978'で始まり、チェックサムで終わっている
    # ようなのでこれを除去してISBNのチェックサムを付加する
    #
    add_checksum(id.gsub(/^.../,'').gsub(/.$/,''))
  end

end
