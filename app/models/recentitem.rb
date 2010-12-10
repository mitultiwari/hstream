class Recentitem < ActiveRecord::Base
  belongs_to :item, :primary_key => :hnid, :foreign_key => :hnid
end
