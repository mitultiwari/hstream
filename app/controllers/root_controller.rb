class RootController < ApplicationController
  def index
    @mostRecentItem, @items = initialize_item_scopes(params)
    @items[:shortlist] = Item.shortlist_children @items[:stream], params[:shortlist]
  end
end
