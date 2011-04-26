require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'notifier'

describe Notifier do
  before(:all) do
    ActionMailer::Base.delivery_method = :test
  end

  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  it 'should foo' do
    Factory(:item, :hnid => 1)
    Notifier.sendEmailsFor(Item.first)
    ActionMailer::Base.deliveries.length.should == 1
  end
end
