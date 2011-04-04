class StoryController < ApplicationController
  def show
    @mostRecentItem, @items = initialize_item_scopes(params)
    @items[:stream] = @items[:stream].where('story_hnid = ?', params[:id])
    @items[:shortlist] = []
  end
end
