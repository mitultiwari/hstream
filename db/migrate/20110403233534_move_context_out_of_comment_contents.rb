class MoveContextOutOfCommentContents < ActiveRecord::Migration
  def self.up
    Item.find(:all).each do |item|
      next unless item.parent
      item.story_hnid = item.contents.gsub(/\n/, ' ').sub(/.*on: <a href="http:\/\/news.ycombinator.com\/item\?id=([0-9]*)">.*/, '\1')
      puts "#{item.id} #{item.hnid} #{item.story_hnid}"
      item.contents = Nokogiri::HTML(item.contents).search('.comment').to_html
      item.save
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
