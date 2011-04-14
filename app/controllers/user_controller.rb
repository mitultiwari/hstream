class UserController < ApplicationController
  def show
    @mostRecentItem, @items = initialize_item_scopes(params)
    @followee = params[:id]
    @id = 'user_'+@followee
    @items[@id] = @items['stream'].where('author = ?', @followee)
    @title = "by <a href='http://news.ycombinator.com/user?id=#{@followee}'>#{@followee}</a>"
    render 'root/show'
  end
end
