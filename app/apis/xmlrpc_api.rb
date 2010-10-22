# 以下のページなどで説明されている。
# http://d.hatena.ne.jp/secondlife/20051113/1131889978
# http://railsapi.masuidrive.jp/class/ActionWebService::Base

class XmlrpcApi < ActionWebService::API::Base
  inflect_names false
  api_method :getIsbnList,
             :returns => [[:string]],
             :expects => [{:shelf => :string}]
end

class XmlrpcService < ActionWebService::Base
  web_service_api XmlrpcApi
  def getIsbnList(shelf)
    shelf = Shelf.find(:first, :conditions => ['name = ?', shelf])
    Entry.find(:all, :conditions => ['shelf_id = ?', shelf.id]).map { |entry| entry.book.isbn }
  end
end

