require 'rails_helper'

describe Events::NewVote do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:motion) { create :motion, discussion: discussion }
  let(:vote) { create :vote, motion: motion, author: user }

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_vote',
                                          eventable: vote,
                                          discussion: vote.discussion,
                                          created_at: vote.created_at)
      Events::NewVote.publish!(vote)
    end

    it 'returns an event' do
      expect(Events::NewVote.publish!(vote)).to eq event
    end
  end
end
