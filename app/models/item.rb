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
    Item.find(:all, :conditions => ["hnid > ? and parent_hnid = ?", self.hnid, self.hnid])
  end

  def levels_of_descendants
    max = 0
    p Item.find(:all).length
    p Item.find(:all).collect{|i|i.hnid}
    items = Item.find(:all, :conditions => ["hnid > ?", self.hnid])
    p items.collect{|i|i.hnid}
    items.each do |item|
      l = levels_below(item)
      max = l if l > max
    end
    max
  end

  def levels_below(item)
    ans = 0
    until !item || item.hnid < self.hnid
      return ans if item.hnid == self.hnid
      ans += 1
      item = item.parent
    end
    -1 # not found
  end
end
