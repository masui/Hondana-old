ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # map.connect '', :controller => 'shelf', :action => 'list'
  # map.connect '', :controller => 'bookshelf', :action => 'list'
  map.root :controller => 'bookshelf', :action => 'list'

  map.connect 'piclens.rss', :controller => 'bookshelf', :action => 'piclens'

  map.connect 'enzan',
              :controller => 'enzan',
              :action => 'index'

  map.connect 'enzan/index.html',
              :controller => 'enzan',
              :action => 'index'
 
  map.connect 'enzan/cmd',
               :controller => 'enzan',
               :action => 'calculate'

  #
  # /iqauth/... というURLはactionとみなすことにする
  #   create
  #   register
  #   getdata
  #
  map.connect 'iqauth/:action/:id',
              :controller => 'iqauth'

  #
  # /bookshelf/... というURLはactionとみなすことにする
  # /bookshelf/list, /bookshelf/search, /bookshelf/alllist, etc.
  # APIに使える?
  #  list => 本棚トップページ
  #  alllist => 全本棚リスト
  #  search => 本検索
  #  shelfsearch => 本棚検索
  #
  map.connect 'bookshelf/:action',
              :controller => 'bookshelf'

  # /bookshelf/search/増井,
  # /bookshelf/shelfsearch/増井, etc.
  # /bookshelf/shelfsearch/Miyashita が何故か動かない
  map.connect 'bookshelf/:action/:q',
              :controller => 'bookshelf'

  # http://hondana.org/masui
  map.connect ':shelfname/',
              :controller => 'shelf',
              :action => 'show',
	      :requirements => { :shelfname => /[^\/]*/ }

  # http://hondana.org/masui/0123456789
  map.connect ':shelfname/:isbn',
              :controller => 'shelf',
              :action => 'edit',
              :requirements => { :isbn => /\d{9}[\dX]/, :shelfname => /[^\/]*/ }

  # http://hondana.org/masui/0123456789.html
  map.connect ':shelfname/:isbn',
              :controller => 'shelf',
              :action => 'edit',
              :requirements => { :isbn => /\d{9}[\dX]\.html/, :shelfname => /[^\/]*/ }

  map.connect ':shelfname/:action',
              :controller => 'shelf',
	      :requirements => { :shelfname => /[^\/]*/ }
#	      :requirements => {}
#              :requirements => { :action => /^(datalist|help|edit|write|newbooks|add|delete|rename|setname|similar|show.*|category_.*|profile_.*|search|cookieset|cookiereset)/ }
#              :requirements => { :action => /^(datalist|help|edit|write|newbooks|add|delete|rename|setname|show|show_.*|category_.*|profile_.*)/ }
#              とするとおかしなことになったのだが...


#  map.connect ':shelfname/:any',
#              :controller => 'shelf',
#              :action => 'show'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
