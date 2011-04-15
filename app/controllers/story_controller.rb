class StoryController < ApplicationController
  def show
    @mostRecentItem, @items = initialize_item_scopes(params)
    @shortlist = (params[:shortlist] || '').split(',')
    @followee = params[:id]
    @id = 'story:'+@followee
    @items[@id] = @items['stream'].where('story_hnid = ?', @followee)
    @title = Item.title_with_hn_link(@followee)
    render 'root/show'
  end
end
