class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :hnid
      t.text :contents
      t.string :author
      t.datetime :timestamp
      t.integer :parent_hnid

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
