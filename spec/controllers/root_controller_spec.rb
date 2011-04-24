require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RootController do
  render_views

  describe "#index" do
    it "should populate @items['stream'] on initial load" do
      Factory(:item, :hnid => 1, :timestamp => 3.seconds.ago)
      Factory(:item, :hnid => 2, :timestamp => 2.seconds.ago)
      Factory(:item, :hnid => 3, :timestamp => 1.second.ago)
      get :index
      assigns(:items)['stream'].map(&:hnid).should == [3, 2, 1]
    end

  end
end
