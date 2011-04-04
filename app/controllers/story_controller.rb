class StoryController < ApplicationController
  def show
    bound = Item.first
    @mostRecentItem = bound.hnid
    @items = {:stream => Item.where('story_hnid = ?', params[:id]).since(params[:mostRecentItem], bound.id)}
    @items[:shortlist] = []
  end
end
