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
      UserMailer.stub_chain(:added_to_group, :deliver)
    end

    it 'delivers UserMailer.added_to_group' do
      pending 'not sure if this should still happen'
      UserMailer.should_receive(:added_to_group).with(membership)
      event.save
    end


    it 'notifies group admins' do
      event.should_receive(:notify!).with(user)
      event.save
    end
  end
end
