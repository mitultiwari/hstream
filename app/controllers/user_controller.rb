class UserController < ApplicationController
  def show
    @mostRecentItem, @items = initialize_item_scopes(params)
    @user = params[:id]
    @id = 'user_'+@user
    @items[@id] = @items[:stream].where('author = ?', params[:id])
  end
end
