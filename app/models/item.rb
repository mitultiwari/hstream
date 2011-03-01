class Item < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Item', :foreign_key => 'parent_hnid', :primary_key => 'hnid'

  def ancestors
    ancestors = []
    x = parent
    while x
      ancestors << x
      x = x.parent
    end
    ancestors
  end

  def children
    Item.find(:all, :conditions => ['hnid > ? and parent_hnid = ?', self.hnid, self.hnid])
  end

  def render_thread
    render_children(20)
  end

  def render_children(max, curr=max-1)
    ans = ''
    return ans unless children
    curr = 1 if curr <= 0
    width = 100.0*curr/max
    margin = 100.0-width
    children.each do |child|
      ans += "<div style='margin-left:#{margin}%; width:#{width}%'>#{child.contents}</div>"
      ans += child.render_children(max, curr-1) if child
    end
    ans
  end

  def story
    contents.gsub(/\n/, ' ').sub(/.*\| on: (<a[^>]*>[^<]*<[^>]*>).*/, '\1')
  end

  def show_contents
    if parent
      return contents.gsub(/\n/, ' ').sub(/\| on: <a[^>]*>[^<]*<[^>]*>/, '')
    end

    contents
  end
end
