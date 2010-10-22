# -*- ruby -*-
# $Date: 2006-05-12 14:31:57 +0900 (Fri, 12 May 2006) $
# $Rev: 27 $
#

$KCODE='utf8'

class MyAmazon
  require 'amazon/aws'
  require 'amazon/aws/search'
  require 'net/http'

  ASSOC_ID =  "pitecancom-22"  # 増井のアソシID
  ACCESS_KEY_ID = '1TFQ8M0E4GRS65KYWX02'

  def initialize
    @rg = Amazon::AWS::ResponseGroup.new('Small')
    @req = Amazon::AWS::Search::Request.new(ACCESS_KEY_ID)
    @req.locale = 'jp'
    @product = {}
  end

  def get_data(isbn)
    if @product[isbn].nil? then
      begin
        @il = Amazon::AWS::ItemLookup.new('ASIN', {'ItemId' => isbn})
        res = @req.search(@il, @rg)
        @product[isbn] = res.item_lookup_response.items.item.item_attributes
      rescue
      end
    end
  end

  def publisher(isbn)
    get_data(isbn)
    if @product[isbn].nil? then
      ''
    else
      @product[isbn].manufacturer.to_s
     end
  end

  def authors(isbn)
    get_data(isbn)
    s = ''
    if !@product[isbn].nil? && !@product[isbn].author.nil? then
      s = @product[isbn].author.collect { |author|
        author.to_s
      }.join(", ")
    end
    s
  end

  def title(isbn)
    get_data(isbn)
    if @product[isbn].nil? then
      ''
    else
      @product[isbn].title.to_s
    end
  end

  def kinokuniya_image(isbn)
    cands = [
      ["bookweb.kinokuniya.co.jp","/imgdata/#{isbn}.jpg"],
    ]
    imageurl(isbn,cands)
  end

  def image(isbn)
    cands = [
      ["images-jp.amazon.com", "/images/P/#{isbn}.01._OU09_PE0_SCMZZZZZZZ_.jpg"], # 2006/3/6 tsuika
      ["images-jp.amazon.com", "/images/P/#{isbn}.09.MZZZZZZZ.jpg"],
      ["images-jp.amazon.com", "/images/P/#{isbn}.01.MZZZZZZZ.jpg"],
      ["bookweb.kinokuniya.co.jp","/imgdata/#{isbn}.jpg"],
    ]
    imageurl(isbn,cands)
  end

  def imageurl(isbn,cands)
#    cands = [
#      ["images-jp.amazon.com", "/images/P/#{isbn}.09.MZZZZZZZ.jpg"],
#      ["images-jp.amazon.com", "/images/P/#{isbn}.01.MZZZZZZZ.jpg"],
#      ["bookweb.kinokuniya.co.jp","/imgdata/#{isbn}.jpg"],
#    ]

    ret = ""
    cands.each { |c|
      host = c[0]
      path = c[1]
      url = "http://#{host}#{path}"
      response = ''
      Net::HTTP.start(host, 80) { |http|
        response = http.get(path)
      }
      if response.class == Net::HTTPOK && response.body.length > 1000 then
        ret = url
        break
      end
    }
    ret
  end

  def url(isbn)
    "http://www.amazon.co.jp/exec/obidos/ASIN/#{isbn}/#{ASSOC_ID}/ref=nosim/"
  end
end

if __FILE__ == $0 then
  amazon = MyAmazon.new
  isbn = '487295114X'
  isbn = '0262011530'
  puts amazon.title(isbn)
  puts amazon.publisher(isbn)
  puts amazon.authors(isbn)
  puts amazon.url(isbn)
end

