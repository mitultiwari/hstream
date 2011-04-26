class NotificationMailer < ActionMailer::Base
  default :from => "HackerStream <feedback@readwarp.com>"

  def author_email
    mail :to => 'akkartik@gmail.com', :subject => 'test1'
  end
end
