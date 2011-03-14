class RootController < ApplicationController
  def index
    @recentItems = Item.since(params[:mostRecentItem])
    @mostRecentItem = @recentItems[0].hnid rescue params[:mostRecentItem]

    params[:shortlist] ||= ''
    shortlist_ids = params[:shortlist].split(',').collect{|x| x.to_i}
    @shortlist = Item.shortlist_children(@recentItems, shortlist_ids)
  end
end
