require 'spec_helper'

describe Login do
  describe 'create_or_merge' do
    before do
      @existing_email = Email.create :email => 'existing@example.com'
      Login.create :email => @existing_email, :shortlist => 'a,b'
    end
    it 'should handle new emails' do
      Login.create_or_merge('new@example.com', 'a,b,c').email.email.should == 'new@example.com'
    end
    it 'should handle existing emails' do
      Login.create_or_merge('existing@example.com', 'a,b,c').email.email.should == 'existing@example.com'
      Login.create_or_merge('existing@example.com', 'a,b,c').email_id.should == @existing_email.id
    end
    it 'should save the union of shortlists for existing emails' do
      Login.create_or_merge('existing@example.com', 'c,a')
      Login.find_by_email_id(@existing_email.id).shortlist.should == 'a,b,c'
    end
  end
end
