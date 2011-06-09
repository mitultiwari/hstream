class FilteredStreamController < ApplicationController
  def index
    dummy, @items = initialize_item_scopes(params)
    @mostRecentItem = nil
    @items['filtered_stream'] = session[:user].stream @items['stream'] if session[:user]
  end
end
