class RootController < ApplicationController
  def index
    @recentItems = Item.find(:all, :order => "hnid desc", :limit => 10)
  end
  
  def foo
    @recentItems = Item.find(:all, :conditions => ["hnid > ?", params[:mostRecentItem]], :order => "hnid desc", :limit => 10)
    @mostRecentItem = @recentItems[0].hnid unless @recentItems.blank?
  end
end
