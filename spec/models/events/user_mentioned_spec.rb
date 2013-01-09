require 'spec_helper'

describe Events::UserMentioned do
  let(:comment){ mock_model(Comment)}
  let(:mentioned_user) { mock_model(User,
                              :subscribed_to_mention_notifications? => false) }

  describe "::publish!" do
    let(:event) { stub(:event, :notify_users! => true) }

    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'user_mentioned',
                                          eventable: comment,
                                          user: mentioned_user)
      Events::UserMentioned.publish!(comment, mentioned_user)
    end

    it 'returns an event' do
      Events::UserMentioned.publish!(comment, mentioned_user).should == event
    end
  end

  context "after event has been published" do
    let(:comment_author) { mock_model(User) }
    let(:event) { Events::UserMentioned.new(kind: "user_mentioned",
                                            eventable: comment,
                                            user: mentioned_user) }

    before { comment.stub(:user).and_return(comment_author) }

    it 'notifies the mentioned user' do
      event.should_receive(:notify!).with(mentioned_user)
      event.save
    end

    context 'mentioned user is subscribed to email notifications' do
      before do
        mentioned_user.should_receive(:subscribed_to_mention_notifications?).
                                      and_return(true)
        UserMailer.stub_chain(:mentioned, :deliver)
      end

      it 'emails the mentioned user to say they were mentioned' do
        UserMailer.should_receive(:mentioned).with(mentioned_user, comment)
        event.save
      end
    end

    context 'mentioned user is comment author' do
      let(:mentioned_user) { comment_author }

      it 'does not notify the mentioned user' do
        event.should_not_receive(:notify!)
        event.save
      end
    end
  end
end