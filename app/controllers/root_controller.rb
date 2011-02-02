class RootController < ApplicationController
  def index
    @recentitems = Recentitem.find(:all)
  end
  
  def foo
    @recentitems = Recentitem.find(:all)
  end
end
