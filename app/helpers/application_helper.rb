module ApplicationHelper
  def layout
    @@layout ||= ActiveSupport::JSON.decode File.open("#{RAILS_ROOT}/config/app.json")
  rescue
    @@layout ||= { 'root' => 'http://news.ycombinator.com',
                   'title' => 'Hacker News in real-time',
                   'topcolor' => '#ff6600',
                 }
  end
end
