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

    it 'should return items added since arg' do
      Item.since(@one.hnid).should == [@two]
      Item.since(@one.hnid.to_s).should == [@two]
    end

    it 'should accept an optional bound id (*not* hnid)' do
      Item.since(@one.hnid, @one.id).should == []
    end
  end
end
