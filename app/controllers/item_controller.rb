class ItemController < ApplicationController
  def show
    @item = Item.find_by_hnid(params[:id])
  end
end
