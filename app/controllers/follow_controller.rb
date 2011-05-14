class FollowController < ApplicationController
  def create
    return render(:text => '') unless session[:user]
    session[:user].add_shortlist(params[:id])
    render(:text => '')
  end

  def destroy
    return render(:text => '') unless session[:user]
    session[:user].del_shortlist(params[:id])
    render(:text => '')
  end
end
