require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RootController do
  describe "#index" do
    it "should populate @items['stream'] on initial load" do
      Factory(:item, :hnid => 1)
      Factory(:item, :hnid => 2)
      Factory(:item, :hnid => 3)
      get :index
      assigns(:items)['stream'].map(&:hnid).should == [3, 2, 1]
    end

  end
end
