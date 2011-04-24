require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RootController do
  render_views

  before do
    Factory(:item, :hnid => 1, :timestamp => 3.seconds.ago, :author => 'foo')
    Factory(:item, :hnid => 2, :timestamp => 2.seconds.ago, :title => 'story')
    Factory(:item, :hnid => 3, :timestamp => 1.second.ago, :story_hnid => 2)
  end

  describe "#index" do
    it "should populate @items['stream'] on initial load" do
      get :index
      assigns(:items)['stream'].map(&:hnid).should == [3, 2, 1]
    end

    it 'should put the appropriate item up top when given params[:item]' do
      get :index, :item => 2
      assigns(:items)['stream'].map(&:hnid).should == [2, 3, 1]
    end

    it 'should include additional column for user' do
      get :index, :columns => 'stream,user:foo'
      assigns(:items)['user:foo'].map(&:hnid).should == [1]
    end

    it 'should include additional column for story' do
      get :index, :columns => 'stream,story:2'
      assigns(:items)['story:2'].map(&:hnid).should == [3]
    end

  end
end
