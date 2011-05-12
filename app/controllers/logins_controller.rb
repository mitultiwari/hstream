class LoginsController < ApplicationController
  def create
    session[:user] = Login.find_or_create_by_email(params[:email])
  end
end
