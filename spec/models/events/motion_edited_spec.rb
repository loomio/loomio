require 'rails_helper'

describe Events::MotionEdited do
  let(:motion) { create :motion, author: user }
  let(:user) { create :user, email: 'bill@dave.com' }

  describe "::publish!" do

    it 'creates a record edit' do
      motion.name = 'changed'
      event = Events::MotionEdited.publish!(motion, user)
      expect(event.eventable.previous_values.keys).to eq(["name"])
      expect(event.eventable.persisted?).to be true
      expect(event.persisted?).to be true
    end
  end
end
