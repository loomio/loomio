require 'rails_helper'

describe Events::NewVote do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:motion) { create :motion, discussion: discussion }
  let(:vote) { create :vote, motion: motion, author: user }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::NewVote.publish!(vote) }.to change { Event.where(kind: 'new_vote').count }.by(1)
    end

    it 'returns an event' do
      expect(Events::NewVote.publish!(vote)).to be_a Event
    end
  end
end
