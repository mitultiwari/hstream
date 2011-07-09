class LoginsController < ApplicationController
  def create
    @me = Login.create_or_merge(params[:email], params[:shortlist])
    session[:user_id] = @me.id
    Subscription.create_for_all_authors(@me, session[:pending_subscribes])
    session[:pending_subscribes] = nil
    cookies['email'] = session[:user].email
  end

  def destroy
    session[:user_id] = nil
    cookies['email'] = nil
    render :text => ''
  end
end
