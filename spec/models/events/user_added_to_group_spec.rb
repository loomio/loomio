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

  context "after event has been published" do
    let(:user) { mock_model(User) }
    let(:group) { mock_model(Group) }
    let(:event) { Events::UserAddedToGroup.new(kind: "user_added_to_group",
                                               user: inviter,
                                               eventable: membership) }

    before do
      membership.stub(:user).and_return(user)
      membership.stub(:group).and_return(group)
      membership.stub(:inviter).and_return(inviter)
      UserMailer.stub_chain(:added_to_a_group, :deliver)
    end

    it 'notifies the requestor' do
      event.should_receive(:notify!).with(user)
      event.save!
    end
  end
end
