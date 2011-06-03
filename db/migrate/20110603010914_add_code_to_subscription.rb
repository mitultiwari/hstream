class AddCodeToSubscription < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :code, :string
    add_index :subscriptions, :code, :unique => true
    Subscription.all.each do |sub|
      sub.code = SecureRandom.hex(6)
      sub.save
    end
  end

  def self.down
    remove_column :subscriptions, :code
    remove_index :subscriptions, :code
  end
end
