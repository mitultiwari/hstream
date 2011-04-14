class UserController < ApplicationController
  def show
    @mostRecentItem, @items = initialize_item_scopes(params)
    @items[:user] = @items[:stream].where('author = ?', params[:id])
    @user = params[:id]
    @id = 'user_'+@user
  end
end
