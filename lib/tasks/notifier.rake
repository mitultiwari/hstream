namespace :notifier do
  desc "monitor new items as they get crawled and send out email notifications"
  task :run => :environment do
    require 'notifier'
    Notifier.run
  end

end
