class NotificationMailer < ActionMailer::Base
  default :from => "HackerStream <feedback@readwarp.com>"

  def author_email(email, author, hnid)
    @hnid = hnid
    mail :to => email, :subject => "New story on HN by #{author}"
  end

  def pattern_email(email, pattern, hnid)
    @hnid = hnid
    mail :to => email, :subject => "New story on HN about #{pattern}"
  end
end
