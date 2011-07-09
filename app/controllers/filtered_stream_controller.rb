class FilteredStreamController < ApplicationController
  def index
    dummy, @items = initialize_item_scopes(params)
    @mostRecentItem = nil
    @items['filtered_stream'] = @me.stream @items['stream'] if @me
  end
end
