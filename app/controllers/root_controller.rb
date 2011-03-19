class RootController < ApplicationController
  def index
    @stream = Item.since(params[:mostRecentItem])
    @shortlist = Item.shortlist_children(@stream, params[:shortlist])
    @mostRecentItem = @stream[0].hnid rescue params[:mostRecentItem]
  end
end
