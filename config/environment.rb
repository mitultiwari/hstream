# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Hnrt::Application.initialize!

ActionMailer::Base.raise_delivery_errors = false
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address => "mail.authsmtp.com",
    :port => 25,
    :user_name => "ac49284",
    :password => "mjvv6tfhm",
    :authentication => :login,
    :enable_starttls_auto => false,
}
