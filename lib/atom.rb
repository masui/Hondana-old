class Time
  def rsstime
    strftime("%Y-%m-%dT%H:%M:%SZ")
  end
end

# createdはFeedValidatorに怒られるのだが

class Atom
  def initialize
  end

  def xmlhead
    <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<?xml-stylesheet href="http://www.blogger.com/styles/atom.css" type="text/css"?>
EOF
  end

# <link href="#{params['link']}" rel="alternate" title="#{params['title']}" type="text/html"/>
  def head(params)
#<link href="#{params['link']}" title="#{params['title']}" type="text/html"/>
# <link rel="self" href="/atom.xml" />
#<link rel="alternate" href="#{params['link']}" title="#{params['title']}" type="text/html"/>
    <<EOF
<title>#{params['title']}</title>
<subtitle>#{params['subtitle']}</subtitle>
<tagline mode="escaped" type="text/html">#{params['description']}</tagline>
<id>#{params['id']}</id>
<link rel="alternate" href="#{params['link']}" title="#{params['title']}" type="application/atom+xml"/>
<author><name>#{params['author']}</name></author>
<updated>#{params['updated'].rsstime}</updated>
<created>#{params['updated'].rsstime}</created>
EOF
  end

#<link rel="self" href="/" />
#<link rel="self" href="#{params['link']}" />
#<link href="#{params['link']}" rel="service.edit" title="#{params['title']}" type="application/atom+xml" />
  def entry(params)
    <<EOF
<entry>
<title>#{params['title']}</title>
<link rel="alternate" href="#{params['link']}" title="#{params['title']}" type="application/atom+xml" />
<id>#{params['id']}</id>
<published>#{params['published'].rsstime}</published>
<author><name>#{params['author']}</name></author>
<updated>#{params['updated'].rsstime}</updated>
<created>#{params['updated'].rsstime}</created>
<category scheme="http://xmlns.com/wordnet/1.6/" term="#{params['category']}"/>
<summary>#{params['summary']}</summary>
<content type="xhtml">
<div xmlns="http://www.w3.org/1999/xhtml">
#{params['summary']}
<p>
<a href="#{params['link']}"><img src="#{params['image']}" /></a>
</p>
</div>
</content>
</entry>
EOF
  end
end

def write_atom(file)
  a = Atom.new
  File.open(file,"w"){ |f|
    f.puts a.xmlhead
    f.puts

    headparams = {}
    headparams['title'] = '本棚.org'
    headparams['subtitle'] = '書籍情報共有サイト'
    headparams['description'] = '書籍情報共有サイト'
    headparams['id'] = 'tag:www.hondana.org,2005:hondana'
    headparams['link'] = 'http://hondana.org/'
    headparams['author'] = 'Hondana.org'
    headparams['updated'] = Time.now
    headparams['modified'] = Time.now

    f.puts <<EOF
<feed xmlns="http://www.w3.org/2005/Atom">
EOF

    f.puts a.head(headparams)

    newentries = Entry.find(:all, :order => "modtime DESC", :limit => 20)
    newentries[0..20].each { |entry|
      shelf = entry.shelf
      book = entry.book

      entryparams = {}
      s = book.title.to_s
      s.gsub!(/\&/,"&amp;")
      s.gsub!(/"/,"&quot;")
      s.gsub!(/</,"&lt;")
      s.gsub!(/>/,"&gt;")
      entryparams['title'] = s

      # http://www.pst.co.jp/Powersoft/html/htmlChar.htm
#      entryparams['link'] = url_for(:shelfname => shelf.name, :isbn => book.isbn)
      entryparams['link'] = url_for(:controller => 'shelf', :action => 'edit', :shelfname => shelf.name, :isbn => book.isbn)
      entryparams['id'] = "tag:hondana.org,2005:#{shelf.id}-#{book.isbn}"
      entryparams['published'] = book.modtime
      entryparams['author'] = shelf.name
      entryparams['issued'] = book.modtime
      entryparams['updated'] = book.modtime
      entryparams['category'] = 'Books'
      s = entry.comment.to_s
      s.gsub!(/[\r\n]/,'')
      s.gsub!(/\&/,"&amp;")
      s.gsub!(/"/,"&quot;")
      s.gsub!(/</,"&lt;")
      s.gsub!(/>/,"&gt;")
      entryparams['summary'] = s
      entryparams['image'] = book.imageurl
      f.puts a.entry(entryparams)
    }

    f.puts <<EOF
</feed>
EOF
  }
end

