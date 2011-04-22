class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter lambda {
    logger.debug "STAT: #{request.ip} #{request.remote_ip} requested #{request.path}?#{request.query_string} via #{request.referer}"
  }

  def initialize_item_scopes(params)
    bound = params[:until] ? Item.find_by_hnid(params[:until]) : Item.first
    return [bound.hnid, {'stream' => Item.since(params[:mostRecentItem], bound.id)}]
  end
end
