class ApplicationController < ActionController::Base
  protect_from_forgery
  after_filter lambda {
    cookies['email'] = session[:user].email.email if session[:user]
    logger.debug "STAT: #{request.session_options[:id] || 0} #{session_email} #{request.ip} #{request.remote_ip} requested #{request.path}?#{request.query_string} via #{request.referer}"
  }

  def initialize_item_scopes(params)
    bound = params[:until] ? Item.find_by_hnid(params[:until]) : Item.first
    return [bound.hnid, {'stream' => Item.since(params[:mostRecentItem], bound.id)}]
  end

  def session_email
    return 'nil' unless session[:user]
    return 'nil' if session[:user].email.email.blank?
    session[:user].email.email
  end
end
