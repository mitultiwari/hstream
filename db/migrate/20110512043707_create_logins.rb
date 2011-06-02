class CreateLogins < ActiveRecord::Migration
  def self.up
    create_table :logins do |t|
      t.integer :email_id
      t.text :shortlist, :default => ''
      t.timestamps
    end
  end

  def self.down
    drop_table :logins
  end
end
