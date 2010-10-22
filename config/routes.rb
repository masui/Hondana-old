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
  map.connect '', :controller => 'bookshelf', :action => 'list'

  map.connect 'piclens.rss', :controller => 'bookshelf', :action => 'piclens'

  # http://hondana.org/search/keyword
  #map.connect 'search/:q',
  #           :controller => 'search',
  #           :action => 'search'

  #map.connect 'search/search',
  #            :controller => 'search',
  #            :action => 'search'

#   map.connect 'stylesheets/enzan.css'
# 
# #  map.connect 'enzan/enzan.swf'
# #  map.connect 'enzan/index.html'
# 
# map.connect 'enzan/:x'
# 
  map.connect 'enzan',
              :controller => 'enzan',
              :action => 'index'

  map.connect 'enzan/index.html',
              :controller => 'enzan',
              :action => 'index'
 
  map.connect 'enzan/recent.html',
              :controller => 'enzan',
              :action => 'recent'
 
  map.connect 'enzan/:cmd',
               :controller => 'enzan',
               :action => 'calculate'

  map.connect 'iqauth/create/:id',
              :controller => 'iqauth',
              :action => 'create'

  map.connect 'iqauth/register/:id',
              :controller => 'iqauth',
              :action => 'register'

  map.connect 'iqauth/getdata/:id',
              :controller => 'iqauth',
              :action => 'getdata'

  #
  # /bookshelf/... というURLはactionとみなすことにする
  # /bookshelf/search, /bookshelf/alllist, etc.
  #
  map.connect 'bookshelf/:action',
              :controller => 'bookshelf'

#  map.connect 'bookshelf/search',
#              :controller => 'bookshelf',
#              :action => 'search'
#
#  map.connect 'bookshelf/alllist',
#              :controller => 'bookshelf',
#              :action => 'alllist'

  # http://hondana.org/masui
  map.connect ':shelfname/',
              :controller => 'shelf',
              :action => 'show'

  # http://hondana.org/masui/0123456789
  map.connect ':shelfname/:isbn',
              :controller => 'shelf',
              :action => 'edit',
              :requirements => { :isbn => /\d{9}[\dX]/ }

  # http://hondana.org/masui/0123456789.html
  map.connect ':shelfname/:isbn',
              :controller => 'shelf',
              :action => 'edit',
              :requirements => { :isbn => /\d{9}[\dX]\.html/ }

  map.connect ':shelfname/:action',
              :controller => 'shelf',
	      :requirements => {}
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
