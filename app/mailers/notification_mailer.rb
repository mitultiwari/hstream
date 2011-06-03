class NotificationMailer < ActionMailer::Base
  default :from => "HackerStream <feedback@readwarp.com>"

  def email(sub, hnid, subject)
    @sub = sub
    puts "notifying #{sub.email.email} of #{hnid}" unless ENV['RAILS_ENV'] == 'test'
    @hnid = hnid
    mail :to => sub.email.email, :subject => subject
  end
end
