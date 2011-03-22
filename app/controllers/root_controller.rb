class RootController < ApplicationController
  def index
    @items = {:stream => Item.since(params[:mostRecentItem])}
    @items[:shortlist] = Item.shortlist_children @items[:stream], params[:shortlist]
    @mostRecentItem = @items[:stream][0].hnid rescue params[:mostRecentItem]
  end
end
