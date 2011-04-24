require 'spec_helper'

describe Item do
  describe 'since' do
    before do
      @one = Factory(:item, :hnid => 18)
      @two = Factory(:item, :hnid => 2)
    end

    it 'should return recent items given null, empty, or zero arg' do
      Item.since(nil).should == [@two, @one]
      Item.since('').should == [@two, @one]
      Item.since(0).should == [@two, @one]
      Item.since('0').should == [@two, @one]
    end

    it 'should return recent items given non-existent hnid' do
      Item.since(13).should == [@two, @one]
    end

    it 'should return items added since arg' do
      Item.since(@one.hnid).should == [@two]
      Item.since(@one.hnid.to_s).should == [@two]
    end

    it 'should accept an optional bound id (*not* hnid)' do
      Item.since(@one.hnid, @one.id).should == []
      Item.since(nil, @one.id).should == [@one]
    end
  end

  describe 'ancestors' do
    before do
      @story = Factory(:item, :hnid => 2)
      @grandparent = Factory(:item, :hnid => 4, :parent_hnid => 2, :story_hnid => 2)
      @parent = Factory(:item, :hnid => 6, :parent_hnid => 4, :story_hnid => 2)
      @unrelated = Factory(:item, :hnid => 7, :parent_hnid => 5, :story_hnid => 2) # missing
      @curr = Factory(:item, :hnid => 8, :parent_hnid => 6, :story_hnid => 2)
      @curr2 = Factory(:item, :hnid => 9, :parent_hnid => 7, :story_hnid => 2)
    end

    it 'should return all parents except the top-level story' do
      @curr.ancestors.should == [@parent, @grandparent]
    end

    it 'should include the top-level story if it has a description' do
      @story.contents = 'contents'
      @story.save
      @curr.ancestors.should == [@parent, @grandparent, @story]
    end

    it 'should return parents upto missing item' do
      @curr2.ancestors.should == [@unrelated]
    end
  end
end
