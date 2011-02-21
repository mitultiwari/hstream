class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :hnid, :unique => true
      t.text :contents
      t.string :author
      t.datetime :timestamp
      t.integer :parent_hnid

      t.timestamps
    end

    add_index :items, :hnid
  end

  def self.down
    drop_table :items
    remove_index :items, :hnid
  end
end
