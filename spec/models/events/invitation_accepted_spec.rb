require 'spec_helper'

describe Events::InvitationAccepted do
  let(:membership){ mock_model(Membership) }

  describe "::publish!" do
    let(:event) { stub(:event, notify_users!: true) }
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

  context "after event has been published" do
    let(:user) { mock_model(User) }
    let(:event) { Events::InvitationAccepted.new(kind: "invitation_accepted",
                                           eventable: membership) }

    before do
      membership.stub(:user).and_return(user)
    end

    it 'notifies the requestor' do
      event.should_receive(:notify!).with(user)
      event.save!
    end
  end
end
