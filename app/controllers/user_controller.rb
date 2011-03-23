class UserController < ApplicationController
  def show
    @items = Item.order('id desc').where('author = ?', params[:id]).limit(20)
  end
end
