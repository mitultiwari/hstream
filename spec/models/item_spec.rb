require 'spec_helper'

describe Item do
  describe 'shortlist_children' do
    before do
      @one = Factory(:item, :hnid => 11, :author => 'joe', :parent_hnid => 10)
      @two = Factory(:item, :hnid => 12, :parent_hnid => 11)
    end

    it 'should return [] by default' do
      Item.shortlist_children([@one, @two], '').should == []
    end

    it 'should intersect ids against new item parents' do
      Item.shortlist_children([@one, @two], '10').should == [@one]
    end

    it 'should handle a comma-separated list' do
      Item.shortlist_children([@one, @two], '10,11').should == [@one, @two]
    end

    it 'should handle non-digits in the shortlist' do
      Item.shortlist_children([@one, @two], '11,abc,def').should == [@two]
    end

    it 'should handle non-digits in the shortlist' do
      dummy = Factory(:item, :hnid => 13, :parent_hnid => 34)
      Item.shortlist_children([@one, @two, dummy], '11,joe,def').should == [@one, @two]
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
