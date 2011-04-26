class Email < ActiveRecord::Base
  has_many :subscriptions
end
