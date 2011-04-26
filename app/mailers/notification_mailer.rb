class NotificationMailer < ActionMailer::Base
  default :from => "HackerStream <feedback@readwarp.com>"

  def email(email, hnid, subject)
    puts "notifying #{email} of #{hnid}" unless ENV['RAILS_ENV'] == 'test'
    @hnid = hnid
    mail :to => email, :subject => subject
  end
end
