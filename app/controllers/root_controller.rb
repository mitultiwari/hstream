class RootController < ApplicationController
  def index
    @mostRecentItem, @items = initialize_item_scopes(params)
    if session[:user] && initial_load?
      @items['my_stream'] = session[:user].stream @items['stream']
    end

    currItem = Item.find_by_hnid(params[:item]) if params[:item]
    currItem = Item.where(:author => params[:user]).first if params[:user]
    @items['stream'] = [currItem]+(@items['stream']-[currItem]) if currItem

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

  def reply
    redirect_to "http://news.ycombinator.com/item?id=#{params[:id]}"
  end

  def initial_load?
    params[:format].blank?
  end
end
