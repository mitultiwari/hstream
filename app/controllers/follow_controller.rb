class FollowController < ApplicationController
  def create
    if session[:user]
      session[:user].add_shortlist(params[:id])
      Subscription.create_for_author(session[:user], params[:id])
    else
      session[:pending_subscribes] ||= []
      session[:pending_subscribes] << params[:id]
    end
    render(:text => '')
  end

  def destroy
    if session[:user]
      session[:user].del_shortlist(params[:id])
      Subscription.find_by_email_id_and_author(session[:user].email_id, params[:id]).destroy rescue nil
    else
      session[:pending_subscribes] ||= []
      session[:pending_subscribes] = session[:pending_subscribes]-[params[:id]]
    end
    render(:text => '')
  end
end
