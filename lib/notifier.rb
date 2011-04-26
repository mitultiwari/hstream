module Notifier
  def sendEmailsFor(item)
    NotificationMailer.pattern_email('akkartik@gmail.com', 'akkartik', '64').deliver
  end

  def run
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
