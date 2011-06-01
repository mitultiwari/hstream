class Notifier
  def self.sendEmailsFor(item)
    emailsNotified = Set.new
    Subscription.all.each do |sub|
      next if emailsNotified.include?(sub.email.email)

      next if !sub.author_to_ignore.blank? && sub.author_to_ignore == item.author

      if !sub.pattern.blank? &&
         ((item.contents && item.contents.gsub(/\n/, ' ') =~ /\b#{sub.pattern}\b/) ||
           (item.is_story? && item.title =~ /\b#{sub.pattern}\b/))
        NotificationMailer.email(sub.email.email, item.hnid,
                                "New story on HN about #{sub.pattern}").deliver
        emailsNotified << sub.email.email
      elsif !sub.author.blank? && sub.author == item.author
        NotificationMailer.email(sub.email.email, item.hnid,
                                "New story on HN by #{sub.author}").deliver
        emailsNotified << sub.email.email
      end
    end
  end

  def self.run
    mostRecentId = Item.first.id
    while true
      sleep 30
      puts Time.now
      curr = Item.first.id
      Item.where('id > ? and id <= ?', mostRecentId, curr).each do |item|
        sendEmailsFor(item)
      end
      mostRecentId = curr
    end
  end
end
