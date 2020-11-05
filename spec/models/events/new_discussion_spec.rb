require 'rails_helper'

describe Events::NewDiscussion do
  let(:discussion) { create :discussion, author: user }
  let(:user) { create :user, email: 'bill@dave.com' }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::NewDiscussion.publish!(discussion: discussion) }.to change  { Event.where(kind: 'new_discussion').count }.by(1)
    end

    it 'returns an event' do
      expect(Events::NewDiscussion.publish!(discussion: discussion)).to be_a Event
    end
  end
end
