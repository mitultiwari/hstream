class RootController < ApplicationController
  def index
    @recentItems = params[:mostRecentItem].blank? ? [] :
        Item.find(:all, :order => "hnid desc", :limit => 10, :conditions => ["hnid > ?", params[:mostRecentItem]])
    @mostRecentItem = @recentItems[0].hnid rescue params[:mostRecentItem]

    @shortlist = Item.find(:all, :conditions => ["hnid in (?)", params[:shortlist].split(',')])
  end
end
