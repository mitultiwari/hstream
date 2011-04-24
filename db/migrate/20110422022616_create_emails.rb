class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.string :email
      t.string :token
      t.boolean :confirmed

      t.timestamps
    end
  end

  def self.down
    drop_table :emails
  end
end
