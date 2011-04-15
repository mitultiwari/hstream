class Item < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Item', :foreign_key => 'parent_hnid', :primary_key => 'hnid'
  belongs_to :story, :class_name => 'Item', :foreign_key => 'story_hnid', :primary_key => 'hnid'
  default_scope order('id desc')

  def is_story?
    parent_hnid.nil?
  end

  def ancestors
    ancestors = []
    x = parent
    while x
      ancestors << x if x.parent_hnid
      x = x.parent
    end
    ancestors
  end

  def self.since(hnid, bound=nil)
    return limit(20) if [nil, '', '0', 0].index(hnid)

    mostRecent = Item.find_by_hnid(hnid)
    return limit(20) unless mostRecent

    ans = limit(10).where('id > ?', mostRecent.id)
    return bound ? ans.where('id <= ?', bound) : ans
  end

  def self.title(hnid)
    story = Item.find_by_hnid(hnid)
    return story.title if story
    aComment = Item.where('story_hnid = ?', hnid).first
    return aComment.title if aComment
    return ''
  end

  def self.title_with_hn_link(hnid)
    title = Item.find_by_hnid(hnid).title.gsub(/<[^>]*>/, '')
    return "<a href='http://news.ycombinator.com/item?id=#{hnid}'>#{title}</a>"
  end
end
