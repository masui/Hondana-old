# -*- coding: utf-8 -*-

class EnzanController < ApplicationController

  require 'enzan'

  #   @@enzan = Enzan.new(url_for())

  #Enzan.new('http://masui.sfc.keio.ac.jp/hondana2','/Users/masui/hondana2')
  #Enzan.new('http://masui.sfc.keio.ac.jp/hondana2','.')

  # Enzan.new('http://masui.sfc.keio.ac.jp/hondana2',RAILS_ROOT)

  Enzan.new(relative_url_root,RAILS_ROOT) # これでいいのかな?

  def index
  end

  def calculate
    (cmd,str) = params[:cmd].split(/&/)
    @res = eval(cmd).out # .split(/[\r\n]/).join("\t")
  end
end
