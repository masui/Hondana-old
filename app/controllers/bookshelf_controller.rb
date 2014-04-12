# -*- coding: utf-8 -*-
class BookshelfController < ApplicationController
#  caches_page :list, :alllist  # トップページのページキャッシュを有効にする

  def search
    @q = params[:q]
    if @q =~ /^\s*$/ then
      redirect_to :action => 'list'
    else
      @books = Book.find(:all, :conditions => ["authors like ? or title like ?", "%"+@q+"%", "%"+@q+"%"])
    end
  end

  def shelfsearch
    @q = params[:q]
    @newentries = Entry.find(:all, :order => "modtime DESC", :limit => 10, :conditions => "NOT comment = ''") # _deletedな本棚の本も見えてしまう
    # @dispshelves = Shelf.find(:all, :order => "modtime DESC", :limit => 15, :conditions => "name like '%#{@q}%' AND NOT name like '%_deleted%'")
    @dispshelves = Shelf.find(:all, :order => "modtime DESC", :limit => 15, :conditions => "name like '%#{@q}%'")
    # SQLite3だと random() MySQLだと rand()
    # @rand10 = Shelf.find(:all, :order => "random()", :limit => 10, :conditions => "NOT name like '%_deleted%'")
    @rand10 = Shelf.find(:all, :order => "rand()", :limit => 10, :conditions => "NOT name like '%_deleted%'")
    #@shelf_pages, @shelves = paginate :shelf, :per_page => 10
    render :action => 'list'
  end

  def list
    cookies[:List] = {
      :value => 'Hondana',
      :expires => 20.minutes.from_now,
      :path => '/',
      :domain => request.domain
    }
    @newentries = Entry.find(:all, :order => "modtime DESC", :limit => 10, :conditions => "NOT comment = ''") # _deletedな本棚の本も見えてしまう
    @dispshelves = Shelf.find(:all, :order => "modtime DESC", :limit => 15, :conditions => "NOT name like '%_deleted%'")
    #@rand10 = Shelf.find(:all, :order => "random()", :limit => 10, :conditions => "NOT name like '%_deleted%'")
    @rand10 = Shelf.find(:all, :order => "rand()", :limit => 10, :conditions => "NOT name like '%_deleted%'")
    #@shelf_pages, @shelves = paginate :shelf, :per_page => 10
  end

  def piclens
    @newentries = Entry.find(:all, :order => "modtime DESC", :limit => 10, :conditions => "NOT comment = ''") # _deletedな本棚の本も見えてしまう
    render :partial => 'piclens'
  end

  def alllist
    @allshelves = Shelf.find(:all, :order => "modtime DESC")
  end

  def create
    shelfname = params[:shelfname]
    if shelfname == '' || shelfname.index('<') || shelfname =~ /%3c/i || shelfname =~ /^[\d\w]{32}$/ || cookies[:List] != 'Hondana' then
      redirect_to :action => 'list'
    else
      @shelf = Shelf.find(:first, :conditions => ["name = ?", shelfname])
      if @shelf.nil? then
        @shelf = Shelf.new
        @shelf.name = params[:shelfname]
        @shelf.description = ''
        @shelf.url = ''
        @shelf.affiliateid = ''
        @shelf.theme = ''
        @shelf.themeurl = ''
        @shelf.listtype = 'image'
        @shelf.sorttype = 'recent'
        @shelf.modtime = Time.now
        @shelf.save
      end
      redirect_to :controller => 'shelf', :action => 'show', :shelfname => @shelf.name
    end
  end
end
