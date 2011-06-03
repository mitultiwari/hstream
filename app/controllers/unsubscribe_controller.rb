class UnsubscribeController < ApplicationController
  def show # can't use delete; will be clicked on from emails
    @subscription = Subscription.find_by_code(params[:id])
    @subscription.destroy
    render :layout => false
  end
end
