class Item < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Item', :foreign_key => 'parent_hnid', :primary_key => 'hnid'

  def ancestors
    ancestors = []
    x = parent
    while x
      ancestors << x
      x = x.parent
    end
    ancestors.reverse
  end
end
