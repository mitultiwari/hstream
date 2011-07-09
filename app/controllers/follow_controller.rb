class FollowController < ApplicationController
  def create
    if @me
      @me.add_shortlist(params[:id])
      Subscription.create_for_author(@me, params[:id])
    else
      session[:pending_subscribes] ||= []
      session[:pending_subscribes] << params[:id]
    end
    render(:text => '')
  end

  def destroy
    if @me
      @me.del_shortlist(params[:id])
      Subscription.find_by_email_id_and_author(@me.email_id, params[:id]).destroy rescue nil
    else
      session[:pending_subscribes] ||= []
      session[:pending_subscribes] = session[:pending_subscribes]-[params[:id]]
    end
    render(:text => '')
  end
end
