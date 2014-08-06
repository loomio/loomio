require 'rails_helper'

describe Events::NewDiscussion do
  let(:discussion){ mock_model(Discussion, group: double(:group), touch: true) }

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_discussion',
                                          eventable: discussion,
                                          discussion_id: discussion.id)
      Events::NewDiscussion.publish!(discussion)
    end

    it 'returns an event' do
      Events::NewDiscussion.publish!(discussion).should == event
    end
  end

  context "after event has been published" do
    let(:user){ mock_model(User) }
    let(:event) { Events::NewDiscussion.new(kind: "new_discussion",
                                               eventable: discussion,
                                               discussion_id: discussion.id) }
    before do
      discussion.stub(:group_members_without_discussion_author).and_return([user])
      user.stub(:email_notifications_for_group?).and_return(false)
      UserMailer.stub_chain(:new_discussion, :deliver)
    end

    context 'if user is subscribed to group notification emails' do
      before do
        user.should_receive(:email_notifications_for_group?).with(discussion.group).and_return(true)
      end

      it 'emails group_members_without_motion_author new_motion_created' do
        UserMailer.should_receive(:new_discussion).with(discussion, user)
        event.save
      end
    end

    context 'if user is not subscribed to group notification emails' do
      before do
        user.should_receive(:email_notifications_for_group?).with(discussion.group).and_return(false)
        event.save
      end

      it 'does not email new motion created' do
        UserMailer.should_not_receive(:new_discussion)
        event.save
      end
    end
  end
end
