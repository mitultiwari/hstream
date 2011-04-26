class UserNotificationMailer < ActionMailer::Base
  default :from => "feedback@readwarp.com"

  def author_notification
    mail :to => 'akkartik@gmail.com', :subject => 'test1'
  end
end
