class Item < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Item', :foreign_key => 'parent_hnid', :primary_key => 'hnid'

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
    if parent
      return contents.
              gsub(/1 point/, '').
              gsub(/[0-9] (minutes?|hours?) ago/, '').
              sub(/ \| <[^>]*>parent<[^>]*> \| on: <a[^>]*>[^<]*<[^>]*>/, '').
              sub(/\|/, '&middot;')
    end

    contents
  end

  def self.shortlist_children(new, old_shortlist_ids)
    new.select{|x| old_shortlist_ids.index(x.parent_hnid)}
  end
end
