require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoryController do
  render_views

  before do
    Factory(:item, :hnid => 1, :timestamp => 3.seconds.ago, :title => 'story 1', :author => 'foo')
    Factory(:item, :hnid => 2, :timestamp => 2.seconds.ago, :title => 'story 2', :contents => 'lorem ipsum')
    Factory(:item, :hnid => 3, :timestamp => 1.second.ago, :story_hnid => 2)
    Factory(:item, :hnid => 4, :timestamp => 1.second.ago, :story_hnid => 1)
  end

  describe "#show" do
    it 'should include comments of given story' do
      get :show, :id => '1', :format => 'js'
      assigns(:items)['story:1'].map(&:hnid).should == [4]
    end

    it 'should include additional item for story with description' do
      get :show, :id => '2', :format => 'js'
      assigns(:items)['story:2'].map(&:hnid).should == [3, 2]
    end

  end
end
