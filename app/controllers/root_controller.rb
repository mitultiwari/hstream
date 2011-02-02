class RootController < ApplicationController
  def index
    @recentitems = Recentitem.find(:all)
  end
  
  def foo
    
#update_page do |page|
#      page.alert 'high' 
#    end
  end
end
