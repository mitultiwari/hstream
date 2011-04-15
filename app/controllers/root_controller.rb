class RootController < ApplicationController
  def index
    @mostRecentItem, @items = initialize_item_scopes(params)
    @shortlist = (params[:shortlist] || '').split(',')
    @columns = (params[:columns] || '').split(',')
    @columns.each do |column|
      next if column == 'stream'
      field, value = column.split(':')
      case field
      when 'user': @items[column] = @items['stream'].select{|x| x.author == value}
      when 'story': @items[column] = @items['stream'].select{|x| x.story_hnid == value.to_i}
      end
    end
  end
end
