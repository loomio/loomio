require 'rails_helper'

describe Events::NewVote do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:motion) { create :motion, discussion: discussion }
  let(:vote) { create :vote, motion: motion, author: user }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::NewVote.publish!(vote) }.to change { Event.count(kind: 'new_vote') }.by(1)
    end

    it 'returns an event' do
      expect(Events::NewVote.publish!(vote)).to be_a Event
    end
  end

  describe 'channel_object' do
    it 'uses the group as a channel object' do
      expect(Events::NewVote.publish!(vote).send(:channel_object)).to eq discussion.group
    end
  end
end
