class Subscription < ActiveRecord::Base
  belongs_to :email

  def self.create_for_author(login, followee)
    return if followee =~ /^[0-9]*$/
    return if Subscription.find_by_email_id_and_author(login.email_id, followee)
    Subscription.create :email_id => login.email_id, :author => followee, :code => SecureRandom.hex(6)
  end

  def self.create_for_all_authors(login, followees)
    followees.each do |followee|
      create_for_author login, followee
    end
  end
end
