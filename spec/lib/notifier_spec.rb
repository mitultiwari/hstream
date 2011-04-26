require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'notifier'

describe Notifier do
  before(:all) do
    ActionMailer::Base.delivery_method = :test
  end

  before(:each) do
    ActionMailer::Base.deliveries = []
    Factory(:item, :hnid => 1, :author => 'foo', :title => 'title1', :contents => 'abc')
    @email = Factory(:email, :email => 'foo@example.com')
  end

  it 'should match patterns in contents' do
    Factory(:subscription, :email_id => @email.id, :pattern => 'abc')
    Notifier.sendEmailsFor(Item.find_by_hnid 1)
    ActionMailer::Base.deliveries.length.should == 1
    ActionMailer::Base.deliveries[0].to.should == ["foo@example.com"]
  end

  it 'should match patterns in contents across newlines' do
    Factory(:item, :hnid => 2, :contents => "abc\ndef")
    Factory(:subscription, :email_id => @email.id, :pattern => 'abc def')
    Notifier.sendEmailsFor(Item.find_by_hnid 2)
    ActionMailer::Base.deliveries.length.should == 1
  end

  it 'should match whole words only' do
    Factory(:item, :hnid => 2, :contents => "dabc def")
    Factory(:subscription, :email_id => @email.id, :pattern => 'abc')
    Notifier.sendEmailsFor(Item.find_by_hnid 2)
    ActionMailer::Base.deliveries.length.should == 0
  end

  it 'should match patterns in title' do
    Factory(:subscription, :email_id => @email.id, :pattern => 'title1')
    Notifier.sendEmailsFor(Item.find_by_hnid 1)
    ActionMailer::Base.deliveries.length.should == 1
  end

  it 'should not match patterns in title for comments' do
    Factory(:item, :hnid => 2, :parent_hnid => 1, :title => 'title1')
    Factory(:subscription, :email_id => @email.id, :pattern => 'title1')
    Notifier.sendEmailsFor(Item.find_by_hnid 2)
    ActionMailer::Base.deliveries.should be_empty
  end

  it 'should match author' do
    Factory(:subscription, :email_id => @email.id, :author => 'foo')
    Notifier.sendEmailsFor(Item.find_by_hnid 1)
    ActionMailer::Base.deliveries.length.should == 1
  end

  it 'should respect author_to_ignore' do
    Factory(:item, :hnid => 2, :author => 'bar', :contents => 'abc')
    Factory(:subscription, :email_id => @email.id, :pattern => 'abc', :author_to_ignore => 'foo')
    Notifier.sendEmailsFor(Item.find_by_hnid 1)
    ActionMailer::Base.deliveries.length.should == 0
    Notifier.sendEmailsFor(Item.find_by_hnid 2)
    ActionMailer::Base.deliveries.length.should == 1
  end

  it 'notify each email no more than once of any item' do
    Factory(:subscription, :email_id => @email.id, :pattern => 'abc')
    Factory(:subscription, :email_id => @email.id, :author => 'foo')
    Notifier.sendEmailsFor(Item.find_by_hnid 1)
    ActionMailer::Base.deliveries.length.should == 1
  end
end
