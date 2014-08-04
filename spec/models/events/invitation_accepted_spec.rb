require 'rails_helper'

describe Events::InvitationAccepted do
  let(:membership){ mock_model(Membership) }

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'invitation_accepted',
                                          eventable: membership)
      Events::InvitationAccepted.publish!(membership)
    end

    it 'returns an event' do
      Events::InvitationAccepted.publish!(membership).should == event
    end
  end
end
