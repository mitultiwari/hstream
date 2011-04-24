class StoryController < ApplicationController
  def show
    dummy, @items = initialize_item_scopes(params)
    @mostRecentItem = nil
    @followee = params[:id]
    @title = Item.title_with_hn_link(@followee)

    @id = 'story:'+@followee
    story = Item.find_by_hnid(@followee)
    if story.contents.blank?
      @items[@id] = @items['stream'].where('story_hnid = ?', @followee)
    else
      @items[@id] = @items['stream'].where('story_hnid = ? or hnid = ?', @followee, @followee)
    end
    render 'root/show'
  end
end
