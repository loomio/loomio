require 'spec_helper'

describe Inbox do
  context '#unread_discussions_for(group)' do
    let(:user) {FactoryGirl.create(:user)}

    subject do
      inbox = Inbox.new(user)
      inbox.load
      inbox
    end
  end

end
