class UserController < ApplicationController
  def show
    @mostRecentItem, @items = initialize_item_scopes(params)
    @items[:stream] = @items[:stream].where('author = ?', params[:id])
    @items[:shortlist] = []
    render 'root/index'
  end
end
