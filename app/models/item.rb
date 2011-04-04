class Item < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Item', :foreign_key => 'parent_hnid', :primary_key => 'hnid'
  belongs_to :story, :class_name => 'Item', :foreign_key => 'story_hnid', :primary_key => 'hnid'
  default_scope order('id desc')

  def ancestors
    ancestors = []
    x = parent
    while x.parent
      ancestors << x
      x = x.parent
    end
    ancestors
  end

  def show_title
    contents.sub(/\n/, ' ').sub(/<a [^>]*>([^<]*)<[^>]*>.*/, "<a href='http://news.ycombinator.com/item?id=#{hnid}'>\\1</a>")
  end

  def self.shortlist_children(new, shortlist)
    shortlist ||= ''
    shortlist = shortlist.split(',').map{|x| x=~/^[0-9]+$/ ? x.to_i : x}
    new.select{|x| shortlist.index(x.parent_hnid) || shortlist.index(x.author)}
  end

  def self.since(hnid)
    return limit(20) if [nil, '', '0', 0].index(hnid)
    return where('id > ?', Item.find_by_hnid(hnid).id).limit(10)
  end
end
