class RootController < ApplicationController
  def index
    @recentItems = params[:mostRecentItem].blank? ? [] :
        Item.find(:all, :conditions => ['hnid > ?', params[:mostRecentItem]], :order => 'hnid desc', :limit => 10)
    @mostRecentItem = @recentItems[0].hnid rescue params[:mostRecentItem]

    unless params[:shortlist].blank?
      @shortlist = Item.find(:all, :conditions => ['hnid in (?)', params[:shortlist].split(',')])
    end
  end
end
