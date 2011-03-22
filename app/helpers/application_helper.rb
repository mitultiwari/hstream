module ApplicationHelper
  def htmlstream(id)
    raw "<div id=\"#{id.to_s}\">#{render 'show_items', :items => @items[id]}</div>"
  end
  def jsstream(id)
    raw "$('##{id.to_s}').prepend(\"#{escape_javascript(render 'show_items', :items => @items[id])}\");"
  end

  def layout
    @@layout ||= ActiveSupport::JSON.decode File.open("#{RAILS_ROOT}/config/app.json")
  rescue
    @@layout ||= { 'root' => 'http://news.ycombinator.com',
                   'title' => 'Hacker News in real-time',
                   'topcolor' => '#ff6600',
                 }
  end
end
