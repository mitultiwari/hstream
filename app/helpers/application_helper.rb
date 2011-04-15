module ApplicationHelper
  def htmlstream(id)
    raw "<div id=\"#{id}\">#{render 'root/show_items', :items => @items[id]}
      <div class='holding' style='display:none'></div>
    </div>"
  end
  def jsstream(id)
    return '' if @items[id].blank?
    raw "$('#'+jqEsc('#{id}')+' .holding').prepend(\"#{escape_javascript(render 'root/show_items', :items => @items[id])}\");
    $('#'+jqEsc('#{id}')+' .holding .item:gt('+maxColumnCapacity+')').remove();"
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
