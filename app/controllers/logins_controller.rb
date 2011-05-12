class LoginsController < ApplicationController
  def create
    session[:user] = Login.find_or_create(:email, :email => params[:email],
                                         :shortlist => params[:shortlist])
    session[:user].merge_shortlist(params[:shortlist])
  end
end
