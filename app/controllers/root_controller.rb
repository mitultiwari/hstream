class RootController < ApplicationController
  def index
    @recentItems = params[:mostRecentItem].blank? ? [] :
        Item.find(:all, :conditions => ['hnid > ?', params[:mostRecentItem]], :order => 'hnid desc', :limit => 10)
    @mostRecentItem = @recentItems[0].hnid rescue params[:mostRecentItem]

    @shortlist = []
    unless params[:shortlist].blank?
      shortlist_ids = params[:shortlist].split(',').collect{|x| x.to_i}
      if !params[:refreshShortlist].blank? ||
            @recentItems.index{|x| shortlist_ids & x.ancestors.collect(&:hnid) != []}
        @shortlist = Item.find(:all, :conditions => ['hnid in (?)', shortlist_ids]).
                          sort_by{|x| shortlist_ids.index(x.hnid)}
      end
    end
  end
end
