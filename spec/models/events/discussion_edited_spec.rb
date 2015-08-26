require 'rails_helper'

describe Events::DiscussionEdited do
  let(:discussion) { create :discussion, author: user }
  let(:user) { create :user, email: 'bill@dave.com' }

  describe "::publish!" do

    it 'creates a record edit' do
      discussion.title = 'changed'
      event = Events::DiscussionEdited.publish!(discussion, user)
      expect(event.eventable.previous_values.keys).to eq(["title"])
      expect(event.eventable.persisted?).to be true
      expect(event.persisted?).to be true
    end
  end
end
