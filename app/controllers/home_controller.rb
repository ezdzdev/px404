class HomeController < ApplicationController
  include HomeHelper
  layout :false

  def home
  end

  def top
    @photos = popular(100)
  end
end
