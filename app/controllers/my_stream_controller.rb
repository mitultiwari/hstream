class MyStreamController < ApplicationController
  def index
    dummy, @items = initialize_item_scopes(params)
    @mostRecentItem = nil
    @items['my_stream'] = session[:user].stream @items['stream'] if session[:user]
  end
end
