class HomeController < ApplicationController
  include HomeHelper

  def top
    @authenticated = true
    @photos = popular(100)
  end

  def like
    render json: vote(params[:id], 1)
  end
end