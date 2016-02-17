require 'rails_helper'

describe Events::UserAddedToGroup do
  let(:membership){ create :membership }
  let(:inviter) { create :user }

  describe "::publish!(membership, inviter)" do

    it 'creates an event' do
      expect { Events::UserAddedToGroup.publish!(membership, inviter) }.to change { Event.where(kind: 'user_added_to_group').count }.by(1)
    end

    it 'returns an event' do
      expect(Events::UserAddedToGroup.publish!(membership, inviter)).to be_a Event
    end
  end
end
