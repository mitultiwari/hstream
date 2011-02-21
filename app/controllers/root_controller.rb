class RootController < ApplicationController
  def index
    @recentItems = params[:mostRecentItem].blank? ? [] :
        Item.find(:all, :conditions => ['hnid > ?', params[:mostRecentItem]], :order => 'hnid desc', :limit => 10)
    @mostRecentItem = @recentItems[0].hnid rescue params[:mostRecentItem]

    @shortlist = []
    unless params[:shortlist].blank?
      shortlist_ids = params[:shortlist].split(',').collect{|x| x.to_i}
      @recentItems.index{|x| shortlist_ids & x.ancestors.collect(&:hnid) != []} and
        @shortlist = Item.find(:all, :conditions => ['hnid in (?)', shortlist_ids])
    end
  end
end
