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

  def title_with_hn_link
    "<a href='http://news.ycombinator.com/item?id=#{hnid}'>#{title.gsub(/<[^>]*>/, '')}</a>"
  end
  def self.title_with_hn_link(hnid)
    Item.find_by_hnid(hnid).title_with_hn_link
  end

  def self.active_stories
    Item.find_all_by_hnid(Item.where('parent_hnid is not NULL').limit(200).group('story_hnid').count('story_hnid').top_keys)
  end
  def self.active_users
    Item.limit(200).group('author').count('author').top_keys(20).collect do |user|
      Item.where('author = ?', user).first
    end
  end
end
