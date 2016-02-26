require 'rails_helper'

describe Events::NewCoordinator do
  let(:user){ create(:user) }
  let(:membership){ create(:membership, user: user) }

  describe "::publish!" do

    it 'creates an event' do
      expect { Events::NewCoordinator.publish!(membership, user) }.to change { Event.where(kind: 'new_coordinator').count }.by(1)
    end

    it 'returns an event' do
      expect(Events::NewCoordinator.publish!(membership, user)).to be_a Event
    end
  end
end
