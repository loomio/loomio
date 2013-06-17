require 'spec_helper'

describe Events::MembershipRequested do
  let(:user) {mock_model(User)}
  let(:admin) {mock_model(User, email: 'hello@kitty.com')}
  let(:group) {mock_model(Group, 
                          admins: [admin], 
                          full_name: 'bingo for alcoholics',
                          admin_email: 'stupid@method.com')}
  let(:membership) { mock_model(Membership, 
                                user: user,
                                group: group) }

  describe "::publish!" do
    let(:event) { stub(:event, :notify_users! => true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'membership_requested',
                                          eventable: membership)
      Events::MembershipRequested.publish!(membership)
    end

    it 'returns an event' do
      Events::MembershipRequested.publish!(membership).should == event
    end
  end

  context "after event has been published" do
    let(:admin) { stub(:admin, email: 'hello@kitty.com', language_preference: "en") }
    let(:event) { Events::MembershipRequested.new(kind: "new_comment",
                                                     eventable: membership) }
    before {
      membership.stub(:group_admins).and_return([admin])
      User.stub(:find_by_email).and_return(admin)
    }

    it 'notifies group admins' do
      event.should_receive(:notify!).with(admin)
      event.save
    end
  end
end
