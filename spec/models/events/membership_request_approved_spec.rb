require 'spec_helper'

describe Events::MembershipRequestApproved do
  let(:user) { mock_model(User) }
  let(:group) { mock_model(Group) }
  let(:membership){ mock_model(Membership, user: user, group: group) }

  before do
    UserMailer.stub_chain(:delay, :group_membership_approved)
  end

  describe "::publish!" do
    let(:event) { stub(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'membership_request_approved',
                                          eventable: membership)
      Events::MembershipRequestApproved.publish!(membership)
    end

    it 'returns an event' do
      Events::MembershipRequestApproved.publish!(membership).should == event
    end
  end

  context "after event has been published" do
    let(:event) { Events::MembershipRequestApproved.publish!(membership) }


    it 'notifies the requestor' do
      Events::MembershipRequestApproved.any_instance.should_receive(:notify!).with(user)
      event
    end

    it 'emails the requestor of the approval' do
      delay = stub
      delay.should_receive(:group_membership_approved).with(user, group)
      UserMailer.stub(:delay).and_return(delay)
      event.save!
    end
  end
end
