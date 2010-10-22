# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  @@IMAGEPAT = /\.(jpg|jpeg|png|gif|tif|tiff)$/i
  @@HTMLPAT = /^(http|https|mailto|ftp):/
  @@ISBNPAT = /\d{9}[0-9X]/
  @@CGIPAT = /\w+\.cgi$/

  def expand_tag(s,shelfname)
#    s = s.to_s.dup
#    s.gsub!(/<(\/?(b|br|p|ul|ol|li|dl|dt|dd|hr|pre|blockquote|del))>/i,'LBRA!\1!RBRA')
#    s.gsub!(/</,'&lt;')
#    s.gsub!(/LBRA!([^!]*)!RBRA/,'<\1>')
#    s.gsub!(/\[\[([^\]]*)\]\]/){ link($1,shelfname) }
#    s
    s.to_s.
    gsub(/<(\/?(b|i|br|p|ul|ol|li|dl|dt|dd|hr|pre|blockquote|del))>/i,'LBRA!\1!RBRA').
    gsub(/</,'&lt;').
    gsub(/LBRA!([^!]*)!RBRA/,'<\1>').
    gsub(/\[\[([^\]]*)\]\]/){ link($1,shelfname.to_s) }
  end

  def link(s,shelfname)
    s =~ /^(\S+)\s*(.*)$/
    name = $1
    desc = origdesc = $2
    desc = name if desc == ''
    case name
    when @@HTMLPAT then # URLへのリンク
      "<a href=\"#{name}\">#{desc}</a>"
    when @@ISBNPAT
      name =~ /^((.*):)?(#{@@ISBNPAT})$/
      shelfname = ($2.to_s == '' ? shelfname : $2.to_s)
      isbn = $3
      book = Book.find(:first, :conditions => ['isbn = ?',isbn])
      if book.nil? then
        link_to '('+isbn+'登録)', :shelfname => shelfname, :action => 'newbooks', :isbn => isbn
      else
        link_to book.title, :shelfname => shelfname, :action => 'edit', :isbn => isbn
      end
    when /^(.+):$/
      shelfname = $1
      if origdesc == '' then
        desc = "#{shelfname}の本棚"
      end
      link_to desc, :shelfname => shelfname, :action => 'show'
    when /^(.*)\?$/
      q = $1
      link_to q, :controller=> 'bookshelf', :action => 'search', :q => q
    else
      # link_to desc, :controller => 'search', :action => 'searchone', :q => name, :shelfname => shelfname
      link_to desc, :action => 'search', :q => name
    end
  end
end
