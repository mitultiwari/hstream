class LoginsController < ApplicationController
  def create
    session[:user] = Login.create_or_merge(params[:email], params[:shortlist])
    Subscription.create_for_all_authors(session[:user], session[:pending_subscribes])
    session[:pending_subscribes] = nil
    cookies['email'] = session[:user].email
  end

  def destroy
    session[:user] = nil
    cookies['email'] = nil
    render :text => ''
  end
end
