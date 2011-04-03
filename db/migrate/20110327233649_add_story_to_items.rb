class AddStoryToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :story_hnid, :integer
    add_index :items, :story_hnid, :unique => true
  end

  def self.down
    remove_column :items, :story_hnid
    remove_index :items, :story_hnid
  end
end
