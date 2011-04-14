class StoryController < ApplicationController
  def show
    @mostRecentItem, @items = initialize_item_scopes(params)
    @followee = params[:id]
    @id = 'story_'+@followee
    @items[@id] = @items['stream'].where('story_hnid = ?', @followee)
    @title = Item.title(@followee)
    render 'root/show'
  end
end
