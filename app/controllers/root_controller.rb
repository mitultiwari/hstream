class RootController < ApplicationController
  def index
    @recentItems = Item.since(params[:mostRecentItem])
    @mostRecentItem = @recentItems[0].hnid rescue params[:mostRecentItem]
    @shortlist = Item.shortlist_children(@recentItems, params[:shortlist])
  end
end
