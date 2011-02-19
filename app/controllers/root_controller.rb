class RootController < ApplicationController
  def index
    @recentitems = Recentitem.find(:all)
  end
  
  def foo
    @recentitems = Recentitem.find(:all)
    @mostRecentItem = @recentitems[0].hnid unless @recentitems.blank?
  end
end
