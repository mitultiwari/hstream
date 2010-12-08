class CreateRecentitems < ActiveRecord::Migration
  def self.up
    create_table :recentitems do |t|
      t.integer :hnid

      t.timestamps
    end
  end

  def self.down
    drop_table :recentitems
  end
end
