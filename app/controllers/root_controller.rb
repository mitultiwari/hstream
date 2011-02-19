class RootController < ApplicationController
  def index
    @recentItems = params[:mostRecentItem].blank? ?
        Item.find(:all, :order => "hnid desc", :limit => 10) :
        Item.find(:all, :order => "hnid desc", :limit => 10, :conditions => ["hnid > ?", params[:mostRecentItem]])
    @mostRecentItem = @recentItems[0].hnid unless @recentItems.blank?

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.insert_html :top, 'content', :partial => "show_item"
          page << "mostRecentItem = #{@mostRecentItem};" unless @recentItems.blank?
        end
      }
    end
  end
end
