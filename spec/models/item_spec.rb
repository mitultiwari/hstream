require 'spec_helper'

describe Item do
  before(:each) do
    @grandparent = Factory(:grandparent)
    @uncle = Factory(:uncle)
    @parent = Factory(:parent)
    @item = Factory(:item)
  end

  describe :levels_below do
    it "should work with self" do
      @item.levels_below(@item).should == 0
    end
    it "should work with children" do
      @parent.levels_below(@item).should == 1
    end
    it "should work with grandchildren" do
      @grandparent.levels_below(@item).should == 2
    end
  end

  describe :levels_of_descendants do
    it "should work on leaves" do
      @item.levels_of_descendants.should == 0
    end
    it "should work on internals" do
      @grandparent.levels_of_descendants.should == 2
    end
  end
end
