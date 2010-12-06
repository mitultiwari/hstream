class CreateCrawlerState < ActiveRecord::Migration
  def self.up
    create_table :crawler_state do |t|
      t.integer :most_recent_comment
      t.integer :most_recent_story
    end

    sql = ActiveRecord::Base.connection
    sql.execute("insert into crawler_state(most_recent_comment, most_recent_story) values(0, 0)")
  end

  def self.down
    drop_table :crawler_state
  end
end
