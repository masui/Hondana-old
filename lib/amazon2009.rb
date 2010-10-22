# -*- ruby -*-
#

$KCODE='utf8'

class MyAmazon
  require "cgi"
  require "base64"
  require "digest/sha2"
  require "time"
  require 'net/http'
  require "rexml/document"

  @@aws_host   = "webservices.amazon.co.jp"
  #
  # 増井のAccessKeyとSecretKey
  #
  @@access_key = '1TFQ8M0E4GRS65KYWX02'
  @@secret_key = 'dhBOeLzKqhxZ2byKETCODAugYx+iLWlzpDvRtbgw'
  @@assoc_id =  "pitecancom-22"

  def initialize
    @product = {}
  end

  #
  # 古いopensslのためのHMAC計算
  # http://d.hatena.ne.jp/zorio/20090509/1241886502
  #
  def hmac_sha256(key, message)
    ipad = "\x36"# * 64
    opad = "\x5c"# * 64
    ikey = ipad * 64
    okey = opad * 64
    key.size.times do |i|
      ikey[i] = key[i] ^ ikey[i]
      okey[i] = key[i] ^ okey[i]
    end
    value = Digest::SHA256.digest(ikey + message)
    value = Digest::SHA256.digest(okey + value)
  end

  def get_data(isbn)
    if @product[isbn].nil? then
      @product[isbn] = {}
      begin
        req = [
          "Service=AWSECommerceService",
          "AWSAccessKeyId=#{@@access_key}",
          "Version=2009-06-01",
          "Operation=ItemLookup",
          "ResponseGroup=Small",
          "Timestamp=#{CGI.escape(Time.now.getutc.iso8601)}",
          "ItemId=#{isbn}"
        ]
        req.sort!
        message = ['GET',@@aws_host,'/onca/xml',req.join('&')].join("\n")
        hash = hmac_sha256(@@secret_key, message)
        signature = Base64.encode64(hash).split.join
        req.push("Signature=#{CGI.escape(signature)}")
        path = "/onca/xml?" + req.join('&')
        body = Net::HTTP.get(@@aws_host , path ) 
        doc = REXML::Document.new(body)
        doc.elements.each("ItemLookupResponse/Items/Item/ItemAttributes/Title") { |element| 
          @product[isbn]['title'] = element.text.to_s
        }
        s = doc.elements.collect("/ItemLookupResponse/Items/Item/ItemAttributes/Author"){ |element|
          element.text.to_s
        }
        @product[isbn]['authors'] = s.join(", ")
        doc.elements.each("ItemLookupResponse/Items/Item/ItemAttributes/Manufacturer") { |element| 
          @product[isbn]['publisher'] = element.text.to_s
        }
      rescue
      end
    end
  end

  def publisher(isbn)
    get_data(isbn)
    if @product[isbn].nil? then
      ''
    else
      @product[isbn]['publisher']
     end
  end

  def authors(isbn)
    get_data(isbn)
    s = ''
    if !@product[isbn].nil? && !@product[isbn]['authors'].nil? then
      s = @product[isbn]['authors']
    end
    s
  end

  def title(isbn)
    get_data(isbn)
    if @product[isbn].nil? then
      ''
    else
      @product[isbn]['title']
    end
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
    "http://www.amazon.co.jp/exec/obidos/ASIN/#{isbn}/#{@@assoc_id}/ref=nosim/"
  end
end

if __FILE__ == $0 then
  amazon = MyAmazon.new
  isbn = '0262011530'
  isbn = '4063192393'
  puts amazon.title(isbn)
  puts amazon.publisher(isbn)
  puts amazon.authors(isbn)
  puts amazon.url(isbn)
end

