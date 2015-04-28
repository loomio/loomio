require 'rails_helper'

describe Events::UserAddedToGroup do
  let(:membership){ mock_model(Membership) }
  let(:inviter) { mock_model(User) }

  describe "::publish!(membership, inviter)" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'user_added_to_group',
                                          user: inviter,
                                          eventable: membership)
      Events::UserAddedToGroup.publish!(membership, inviter)
    end

    it 'returns an event' do
      expect(Events::UserAddedToGroup.publish!(membership, inviter)).to eq event
    end
  end
end
