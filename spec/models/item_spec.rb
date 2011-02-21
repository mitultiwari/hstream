require 'spec_helper'

describe Item do
  before(:each) do
    @parent = Factory :item, :hnid => 2
    Factory :item, :hnid => 5, :parent => @parent
    @item = Factory :item, :hnid => 6, :parent => @parent
    @child = Factory :item, :hnid => 10, :parent => @item
  end

  describe :levels_below do
    it "should work with self" do
      @item.levels_below(@item).should == 0
    end
    it "should work with children" do
      @parent.levels_below(@item).should == 1
    end
    it "should work with grandchildren" do
      @parent.levels_below(@child).should == 2
    end
  end

  describe :levels_of_descendants do
    it "should work on leaves" do
      @child.levels_of_descendants.should == 0
    end
    it "should work on internals" do
      @parent.levels_of_descendants.should == 2
    end
  end
end
