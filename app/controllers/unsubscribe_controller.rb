class UnsubscribeController < ApplicationController
  def show # can't use delete; will be clicked on from emails
    @subscription = Subscription.find_by_code(params[:id])
    return render(:status => 404, :file => "#{Rails.root}/public/404.html") unless @subscription
    @subscription.destroy
    render :layout => false
  end
end
