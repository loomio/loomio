require 'spec_helper'

describe Events::UserAddedToGroup do
  let(:membership){ mock_model(Membership) }

  describe "::publish!" do
    let(:event) { stub(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'user_added_to_group',
                                          eventable: membership)
      Events::UserAddedToGroup.publish!(membership)
    end

    it 'returns an event' do
      Events::UserAddedToGroup.publish!(membership).should == event
    end
  end

  context "after event has been published" do
    let(:user) { mock_model(User) }
    let(:event) { Events::UserAddedToGroup.new(kind: "user_added_to_group",
                                           eventable: membership) }

    before do
      membership.stub(:user).and_return(user)
      user.stub(:accepted_or_not_invited?).and_return(false)
      UserMailer.stub_chain(:added_to_group, :deliver)
    end

    context 'accepted_or_not_invited is true' do
      before do
        user.should_receive(:accepted_or_not_invited?).and_return(true)
      end

      it 'delivers UserMailer.added_to_group' do
        UserMailer.should_receive(:added_to_group).with(membership)
        event.save
      end
    end

    context 'accepted_or_not_invited is false' do
      it 'does not deliver UserMailer.added_to_group' do
        UserMailer.should_not_receive(:added_to_group)
        event.save
      end
    end

    it 'notifies group admins' do
      event.should_receive(:notify!).with(user)
      event.save
    end
  end
end