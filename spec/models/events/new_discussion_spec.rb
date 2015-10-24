require 'rails_helper'

describe Events::NewDiscussion do
  let(:discussion) { create :discussion, author: user }
  let(:user) { create :user, email: 'bill@dave.com' }

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true, discussion: discussion, id: 1) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_discussion',
                                          eventable: discussion)
      Events::NewDiscussion.publish!(discussion)
    end

    it 'marks the discussion reader as participating' do
      Events::NewDiscussion.publish!(discussion)
      expect(DiscussionReader.for(user: user, discussion: discussion).participating).to be_truthy
    end

    it 'returns an event' do
      expect(Events::NewDiscussion.publish!(discussion)).to eq event
    end
  end

  describe 'channel_object' do
    it 'uses the discussions group as a channel object' do
      expect(Events::NewDiscussion.publish!(discussion).send(:channel_object)).to eq discussion.group
    end
  end
end
