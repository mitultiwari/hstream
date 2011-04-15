class UserController < ApplicationController
  def show
    @mostRecentItem, @items = initialize_item_scopes(params)
    @shortlist = (params[:shortlist] || '').split(',')
    @followee = params[:id]
    @id = 'user:'+@followee
    @items[@id] = @items['stream'].where('author = ?', @followee)
    @title = "by <a href='http://news.ycombinator.com/user?id=#{@followee}'>#{@followee}</a>"
    render 'root/show'
  end
end
