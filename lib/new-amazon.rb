require 'amazon/aws'
require 'amazon/aws/search'
rg = Amazon::AWS::ResponseGroup.new('Small')
req = Amazon::AWS::Search::Request.new('1TFQ8M0E4GRS65KYWX02')
req.locale = 'jp'

il = Amazon::AWS::ItemLookup.new('ASIN', {'ItemId' => '487295114X'})

res = req.search(il, rg)
puts res.item_lookup_response.items.item.item_attributes
puts res.item_lookup_response.items.item.item_attributes.author
puts res.item_lookup_response.items.item.item_attributes.manufacturer
puts res.item_lookup_response.items.item.item_attributes.title
exit

res = req.search(il, rg) do |page|
  puts page.item_lookup_response.items.item.item_attributes.author
  puts page.item_lookup_response.items.item.item_attributes.manufacturer
  puts page.item_lookup_response.items.item.item_attributes.title
end

# puts "#{key} => #{val}"

exit
#


#require 'amazon/search'
#include Amazon::Search

require 'amazon/aws'
require 'amazon/aws/search'

# We don't want to have to fully qualify identifiers.
#
include Amazon::AWS
include Amazon::AWS::Search
 

DEV_TOKEN = "DPB95W88YXNRE"  # 増井のトークン
ASSOCIATE_ID =  "pitecancom-22"  # 増井のアソシID

ACCESS_KEY_ID = "1TFQ8M0E4GRS65KYWX02"
SECRET_ACCESS_KEY = "dhBOeLzKqhxZ2byKETCODAugYx+iLWlzpDvRtbgw"
 
request = Request.new(ACCESS_KEY_ID)
request.locale = 'jp'
puts request

 
il = ItemLookup.new( 'ASIN', { 'ItemID' => '4274066428' })
#il = ItemLookup.new( 'ASIN', { 'ItemId' => 'B000AE4QEC', 'MerchantId' => 'Amazon' })
puts il

rg = ResponseGroup.new( 'Large' )
puts rg

il.params.each { |key,val|
  puts "#{key} => #{val}"
}

resp = request.search( il, rg)
puts resp
item_sets = resp.item_lookup_response[0].items
puts item_sets

exit



# ASIN/ISBNで検索
res = request.asin_search("4274066428")
exit
 
# ヒット数
puts res.products.size #=> 1 ASINでの検索なので1件のみ該当
 
# ヒットした製品の情報
puts res.products[0]
