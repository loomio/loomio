require 'rails_helper'

describe Events::MembershipRequestApproved do
  let(:requestor) { mock_model(User) }
  let(:approver) { mock_model(User) }
  let(:group) { mock_model(Group) }
  let(:membership){ mock_model(Membership, user: requestor, group: group) }

  before do
    UserMailer.stub_chain(:delay, :group_membership_approved)
  end

  describe "::publish!(membership, approver)" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'membership_request_approved',
                                          user: approver,
                                          eventable: membership)
      Events::MembershipRequestApproved.publish!(membership, approver)
    end

    it 'returns an event' do
      expect(Events::MembershipRequestApproved.publish!(membership, approver)).to eq event
    end
  end

  context "after event has been published" do
    let(:event) { Events::MembershipRequestApproved.publish!(membership, approver) }


    it 'notifies the requestor' do
      Events::MembershipRequestApproved.any_instance.should_receive(:notify!).with(requestor)
      event
    end

    it 'emails the requestor of the approval' do
      delay = double
      delay.should_receive(:group_membership_approved).with(requestor, group)
      UserMailer.stub(:delay).and_return(delay)
      event.save!
    end
  end
end
