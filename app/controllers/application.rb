# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :set_charset

  private
  def set_charset
    headers["Content-Type"] = "text/html; charset=UTF-8"
  end
end

