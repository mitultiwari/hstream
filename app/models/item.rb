class Item < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Item', :foreign_key => 'parent_hnid', :primary_key => 'hnid'
  scope :since, lambda {|hnid| since_scope(hnid)}

  def ancestors
    ancestors = []
    x = parent
    while x.parent
      ancestors << x
      x = x.parent
    end
    ancestors
  end

  def story
    contents.gsub(/\n/, ' ').sub(/.*\| on: (<a[^>]*>[^<]*<[^>]*>).*/, '\1')
  end

  def show_contents
    contents.sub!(/by <[^>]+>([^<]+)<\/[^>]+>/, '\& <a class="follow" author="\1">+</a>')

    if parent
      return contents.
              gsub(/\W[0-9]+ points?/, '').
              gsub(/\W[0-9]+ (minutes?|hours?) ago/, '').
              sub(/ \| <[^>]*>parent<[^>]*> \| on: <a[^>]*>[^<]*<[^>]*>/, '')
    end

    contents
  end

  def self.shortlist_children(new, shortlist)
    shortlist ||= ''
    shortlist = shortlist.split(',').map{|x| x=~/^[0-9]+$/ ? x.to_i : x}
    new.select{|x| shortlist.index(x.parent_hnid) || shortlist.index(x.author)}
  end

  def self.since_scope(hnid)
    return where('id < 0') if hnid.blank?
    return order('hnid desc').limit(20) if ['0', 0].index(hnid)
    where('id > ?', Item.find_by_hnid(hnid).id).order('hnid desc').limit(10)
  end
end
