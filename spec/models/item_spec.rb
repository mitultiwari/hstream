require 'spec_helper'

describe Item do
  describe 'shortlist_children' do
    it 'should return [] by default' do
      Item.shortlist_children([Factory(:item, :hnid => 1), Factory(:item, :hnid => 2)],
                              []).should == []
    end
    it 'should intersect ids against new item parents' do
      one = Factory(:item, :hnid => 1, :parent_hnid => 0)
      two = Factory(:item, :hnid => 2, :parent_hnid => 1)
      Item.shortlist_children([one, two], [0]).should == [one]
    end
  end

  describe 'since' do
    it 'should return empty set given null arg' do
      Item.since('').should be_empty
    end

    it 'should return recent items if given a zero arg' do
      one = Factory(:item, :hnid => 18)
      two = Factory(:item, :hnid => 2)
      Item.since('0').should == [one, two]
    end

    it 'should return items added since arg' do
      one = Factory(:item, :hnid => 18)
      two = Factory(:item, :hnid => 2)
      Item.since(one.hnid).should == [two]
    end
  end
end
