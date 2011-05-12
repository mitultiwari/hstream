class LoginsController < ApplicationController
  def create
    session[:user] = Login.create_or_merge(params[:email], params[:shortlist])
    cookies['email'] = session[:user].email
  end

  def destroy
    session[:user] = nil
    cookies['email'] = nil
    render :text => ''
  end
end
