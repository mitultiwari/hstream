module ApplicationHelper
  def htmlrender(id, partial, options)
    "<div id=\"#{id.to_s}\">#{render partial.to_s, options}</div>"
  end
  def jsrender(id, partial, options)
    "$('##{id.to_s}').prepend(\"#{escape_javascript(render partial.to_s, options)}\");"
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
