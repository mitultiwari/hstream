class MyStreamController < ApplicationController
  def index
    dummy, @items = initialize_item_scopes(params)
    @mostRecentItem = nil
    return unless session[:user]

    shortlist = session[:user].shortlist.split(',')
    t = Item.arel_table
    @items['my_stream'] = @items['stream'].
        where(t[:author].in(shortlist).or(t[:story_hnid].in(shortlist)).or(t[:hnid].in(shortlist)))
  end
end
