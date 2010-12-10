class RootController < ApplicationController
  def index
    @recentitems = Recentitem.find(:all)
  end
end
