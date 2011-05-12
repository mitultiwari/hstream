class LoginsController < ApplicationController
  def create
    session[:user] = Login.create_or_merge(params[:email], params[:shortlist])
    cookies['email'] = session[:user].email
  end
end
