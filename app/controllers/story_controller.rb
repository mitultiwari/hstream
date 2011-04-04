class StoryController < ApplicationController
  def show
    @items = {:stream => Item.since(params[:mostRecentItem])}
    @mostRecentItem = @items[:stream][0].hnid rescue params[:mostRecentItem]
    @items[:stream] = @items[:stream].select{|x| x.story_hnid == params[:id].to_i}
    @items[:shortlist] = []
  end
end
