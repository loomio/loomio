require 'rails_helper'

describe Events::NewDiscussion do
  let(:discussion) { create :discussion, author: user }
  let(:user) { create :user, email: 'bill@dave.com' }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::NewDiscussion.publish!(discussion) }.to change  { Event.count(kind: 'new_discussion') }.by(1)
    end

    it 'returns an event' do
      expect(Events::NewDiscussion.publish!(discussion)).to be_a Event
    end
  end

  describe 'channel_object' do
    it 'uses the discussions group as a channel object' do
      expect(Events::NewDiscussion.publish!(discussion).send(:channel_object)).to eq discussion.group
    end
  end
end
