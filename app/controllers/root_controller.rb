class RootController < ApplicationController
  def index
    bound = Item.first
    @mostRecentItem = bound.hnid
    @items = {:stream => Item.since(params[:mostRecentItem], bound.id)}
    @items[:shortlist] = Item.shortlist_children @items[:stream], params[:shortlist]
  end
end
