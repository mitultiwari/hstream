class StoryController < ApplicationController
  def show
    dummy, @items = initialize_item_scopes(params)
    @mostRecentItem = nil
    @followee = params[:id]
    @title = Item.title_with_hn_link(@followee)

    @id = 'story:'+@followee
    story = Item.find_by_hnid(@followee)
    @items[@id] = @items['stream'].where(:story_hnid => @followee)
    @items[@id] += [Item.find_by_hnid @followee] unless story.contents.blank?
    render 'root/show'
  end
end
