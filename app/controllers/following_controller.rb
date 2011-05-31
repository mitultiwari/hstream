class FollowingController < ApplicationController
  def index
    session[:user].reload if session[:user]
  end
end
