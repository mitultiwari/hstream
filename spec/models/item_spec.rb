require 'spec_helper'

describe Item do
  before(:each) do
    @item = Factory.build(:item)
    @parent = @item.parent
    @grandparent = @parent.parent
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
end
