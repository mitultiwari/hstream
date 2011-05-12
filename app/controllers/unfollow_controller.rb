class UnfollowController < ApplicationController
  def update
    return render(:text => '') unless session[:user]
    session[:user].del_shortlist(params[:id])
    render(:text => '')
  end
end
