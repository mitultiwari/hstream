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
end
