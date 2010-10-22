class XmlrpcController < ApplicationController
  web_service_dispatching_mode :delegated
  web_service_api XmlrpcApi # これがないとXmlrpcServiceがnot foundに
  web_service :api, XmlrpcService.new
end
