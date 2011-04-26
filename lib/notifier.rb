class Notifier
  def self.sendEmailsFor(item)
    Subscription.all.each do |sub|
      next if !sub.author_to_ignore.blank? && sub.author_to_ignore == item.author

      if !sub.pattern.blank? &&
         ((item.contents && item.contents.gsub(/\n/, ' ') =~ /\b#{sub.pattern}\b/) ||
           (item.is_story? && item.title =~ /\b#{sub.pattern}\b/))
        NotificationMailer.pattern_email(sub.email.email, sub.pattern, item.hnid).deliver
      elsif !sub.author.blank? && sub.author == item.author
        NotificationMailer.author_email(sub.email.email, sub.author, item.hnid).deliver
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
