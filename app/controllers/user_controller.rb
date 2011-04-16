class UserController < ApplicationController
  def show
    dummy, @items = initialize_item_scopes(params)
    @mostRecentItem = nil
    @followee = params[:id]
    @id = 'user:'+@followee
    @items[@id] = @items['stream'].where('author = ?', @followee)
    @title = "by <a href='http://news.ycombinator.com/user?id=#{@followee}'>#{@followee}</a>"
    render 'root/show'
  end
end
