class FollowController < ApplicationController
  def update
    return render(:text => '') unless session[:user]
    session[:user].add_shortlist(params[:id])
    render(:text => '')
  end
end
