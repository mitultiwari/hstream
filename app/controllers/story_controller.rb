class StoryController < ApplicationController
  def show
    @mostRecentItem, @items = initialize_item_scopes(params)
    @id = 'story_'+params[:id]
    @items[@id] = @items[:stream].where('story_hnid = ?', params[:id])
    @title = Item.title(params[:id])
  end
end
