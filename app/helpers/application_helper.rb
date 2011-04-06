module ApplicationHelper
  def htmlstream(id)
    raw "<div id=\"#{id}\">#{render 'root/show_items', :items => @items[id]}</div>"
  end
  def jsstream(id)
    return '' if @items[id].blank?
    raw "$('##{id}').prepend(\"#{escape_javascript(render 'root/show_items', :items => @items[id])}\");"
  end

  def layout
    @@layout ||= ActiveSupport::JSON.decode File.open("#{Rails.root}/config/app.json")
  rescue
    @@layout ||= { 'root' => 'http://news.ycombinator.com',
                   'title' => 'Hacker News in real-time',
                   'topcolor' => '#ff6600',
                 }
  end
end
