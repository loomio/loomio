require 'spec_helper'

describe Events::MembershipRequestApproved do
  let(:membership){ mock_model(Membership) }

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
    let(:user) { mock_model(User) }
    let(:group) { mock_model(Group) }
    let(:event) { Events::MembershipRequestApproved.new(kind: "membership_request_approved",
                                           eventable: membership) }

    before do
      membership.stub(:user).and_return(user)
      membership.stub(:group).and_return(group)
      UserMailer.stub_chain(:group_membership_approved, :deliver)
    end

    it 'notifies the requestor' do
      event.should_receive(:notify!).with(user)
      event.save!
    end

    it 'emails the requestor of the approval' do
      UserMailer.should_receive(:group_membership_approved).with(user, group)
      event.save!
    end
  end
end
