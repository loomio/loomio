require 'spec_helper'

describe Event do
  let(:user) { stub(:user, email: 'jon@lemmon.com') }
  let(:event) { stub(:event, :notify! => true) }
  let(:mailer) { stub(:mailer, :deliver => true) }
  let(:discussion) { mock_model Discussion }
  let(:group) { stub(:group) }

  # before do
  #   Event.stub(:create!).and_return(event)
  # end

  describe "new_discussion!", isolated: true do
    before do
      Event.stub(:create!).and_return(event)
      user.stub(:email_notifications_for_group?).and_return(false)
      discussion.stub(:group_users_without_discussion_author).and_return([user])
      discussion.stub(:group).and_return(group)
    end

    after do
      Event.new_discussion!(discussion)
    end

    context 'if user.email_notifications_for_group?' do
      before do
        user.should_receive(:email_notifications_for_group?).with(group).and_return(true)
      end

      it 'calls new_discussion_created' do
        DiscussionMailer.should_receive(:new_discussion_created).with(discussion, user).and_return(mailer)
      end
    end

    context 'if user.email_notifications_for_group? false' do
      before do
        user.should_receive(:email_notifications_for_group?).with(group).and_return(false)
      end
      it 'does not email the user' do
        DiscussionMailer.should_not_receive(:new_discussion_created)
      end
    end

    it 'creates an event with kind and eventable' do
      Event.should_receive(:create!).with(:kind => 'new_discussion',
                                          :eventable => discussion,
                                          :discussion_id => discussion.id).and_return(event)
    end

    it 'notifys users but not the author' do
      event.should_receive(:notify!).with(user)
      discussion.should_receive(:group_users_without_discussion_author).and_return([user])
    end
  end

  describe "new_comment!", isolated: true do
    let(:comment) { stub(:comment) }

    before do
      Event.stub(:create!).and_return(event)
      comment.stub(:discussion).and_return(discussion)
      event.stub(:send_new_comment_notifications!)
    end

    after do
      Event.new_comment!(comment)
    end

    it 'creates an event with kind new_comment and eventable comment' do
      Event.should_receive(:create!).with(kind: 'new_comment',
                                          eventable: comment,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'calls send_new_comment_notifications' do
      event.should_receive(:send_new_comment_notifications!)
    end
  end

  describe "new_motion!", isolated: true do
    let(:user) { stub(:user, :email => 'bill@dave.com') }
    let(:motion) { stub(:motion, :group => group) }

    before do
      Event.stub(:create!).and_return(event)
      user.stub(:email_notifications_for_group?).and_return(false)
      motion.stub(:group_users_without_motion_author).and_return([user])
      motion.stub(:group_email_new_motion?).and_return(false)
      motion.stub(:discussion).and_return(discussion)
    end

    after do
      Event.new_motion!(motion)
    end

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_motion', 
                                          eventable: motion,
                                          discussion_id: discussion.id)
    end

    context 'if user is subscribed to group notification emails' do
      before do
        user.should_receive(:email_notifications_for_group?).with(motion.group).and_return(true)
      end

      it 'emails group_users_without_motion_author new_motion_created' do
        MotionMailer.should_receive(:new_motion_created).with(motion, user).and_return(mailer)
      end
    end

    context 'if user is not subscribed to group notification emails' do
      before do
        user.should_receive(:email_notifications_for_group?).with(motion.group).and_return(false)
      end

      it 'does not email new motion created' do
        MotionMailer.should_not_receive(:new_motion_created)
      end
    end

    it 'notifies group_users_without_motion_author' do
      event.should_receive(:notify!).with(user)
    end
  end

  describe "new_vote!", :isolated => true do
    let(:motion_author) { stub(:motion_author) }
    let(:discussion_author) { stub(:discussion_author) }
    let(:vote) { stub(:vote,
                      user: user,
                      motion_author: motion_author,
                      discussion_author: discussion_author) }
    before do
      Event.stub(:create!).and_return(event)
      event.stub(:send_new_vote_notifications!).with(vote)
      vote.stub_chain(:motion, :discussion).and_return(discussion)
    end

    after do
      Event.new_vote!(vote)
    end

    it 'creates a new_vote event with eventable vote' do
      Event.should_receive(:create!).with(kind: 'new_vote',
                                          eventable: vote,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'calls send_new_vote_notifications!' do
      event.should_receive(:send_new_vote_notifications!)
    end
  end

  describe "motion_closed!" do
    let(:user) { stub(:user) }
    let(:closer) { stub(:user, :email => 'bill@dave.com') }
    let(:motion) { stub(:motion, :group => group) }

    before do
      Event.stub(:create!).and_return(event)
      motion.stub(:discussion).and_return(discussion)
      motion.stub(:author).and_return(closer)
      motion.stub(:group_users).and_return([user])
      MotionMailer.stub_chain(:motion_closed, :deliver)
    end

    after do
      Event.motion_closed!(motion, closer)
    end

    it 'emails group_users motion_closed' do
      MotionMailer.should_receive(:motion_closed).with(motion, closer.email).and_return(mailer)
    end

    it 'creates a motion_closed event' do
      Event.should_receive(:create!).with(kind: 'motion_closed',
                                          eventable: motion,
                                          user: closer,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'notifies other group members' do
      event.should_receive(:notify!).with(user)
    end

    it 'does not notify other the closer' do
      event.should_not_receive(:notify!).with(closer)
    end
  end

  describe "motion_blocked!" do
    let(:vote) { stub(:vote, other_group_members: [user]) }

    before do
      Event.stub(:create!).and_return(event)
      vote.stub_chain(:motion, :discussion).and_return(discussion)
    end

    after do
      Event.motion_blocked!(vote)
    end

    it 'creates a motion_blocked event' do
      Event.should_receive(:create!).with(kind: 'motion_blocked',
                                          eventable: vote,
                                          discussion_id: discussion.id).and_return(event)
    end

    it 'notifies other group members' do
      vote.should_receive(:other_group_members).and_return([user])
      event.should_receive(:notify!).with(user)
    end
  end

  describe "membership_requested!", isolated: true do
    let(:membership) { stub(:membership) }

    before do
      Event.stub(:create!).and_return(event)
      membership.stub(:group_admins).and_return([user])
    end

    after do
      Event.membership_requested!(membership)
    end

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'membership_requested',
                                          eventable: membership)
    end

    it 'notifies group admins' do
      event.should_receive(:notify!).with(user)
    end
  end

  describe "user_added_to_group!", isolated: true do
    let(:membership) { stub(:membership, user: user) }

    before do
      Event.stub(:create!).and_return(event)
      user.stub(:accepted_or_not_invited?).and_return(false)
    end

    after do
      Event.user_added_to_group!(membership)
    end

    it 'creates a user_added_to_group event' do
      Event.should_receive(:create!).with(kind: 'user_added_to_group',
                                          eventable: membership).
                                          and_return(event)
    end

    it 'notifies the user' do
      event.should_receive(:notify!).with(user)
    end

    context 'accepted_or_not_invited is true' do
      before do
        user.should_receive(:accepted_or_not_invited?).and_return(true)
      end

      it 'delivers UserMailer.added_to_group' do
        UserMailer.should_receive(:added_to_group).with(membership).and_return(mailer)
      end
    end

    context 'accepted_or_not_invited is false' do
      it 'does not deliver UserMailer.added_to_group' do
        UserMailer.should_not_receive(:added_to_group)
      end
    end
  end

  describe "comment_liked!", isolated: true do
    let(:commenter) { stub(:commenter) }
    let(:voter) { stub(:voter) }
    let(:comment_vote) { stub(:comment_vote,
                              comment_user: commenter,
                              user: voter) }
    before do
      Event.stub(:create!).and_return(event)
    end

    after do
      Event.comment_liked!(comment_vote)
    end

    it 'creates a comment_liked event' do
      Event.should_receive(:create!).with(kind: 'comment_liked',
                                          eventable: comment_vote).
                                          and_return(event)
    end

    it 'notifies the comment author' do
      event.should_receive(:notify!).with(commenter)
    end

    context 'voter is commenter' do
      before do
        comment_vote.stub(:user).and_return(commenter)
      end

      it 'does not notify the user' do
        event.should_not_receive(:notify!).with(user)
      end
    end
  end

  describe "user_mentioned!", isolated: true do
    let(:comment_author) { stub(:comment_author) }
    let(:comment) { stub(:comment, user: comment_author) }
    let(:mentioned_user) { stub(:mentioned_user,
                                :subscribed_to_mention_notifications? => false) }

    before do
      Event.stub(:create!).and_return(event)
    end

    after do
      Event.user_mentioned!(comment, mentioned_user)
    end

    it 'creates a user_mentioned event' do
      Event.should_receive(:create!).
        with(kind: 'user_mentioned', eventable: comment).
        and_return(event)
    end

    it 'notifies the mentioned user' do
      event.should_receive(:notify!).with(mentioned_user)
    end

    context 'mentioned user is subscribed to email notifications' do
      before do
        mentioned_user.should_receive(:subscribed_to_mention_notifications?).and_return(true)
      end

      it 'emails the user to say they were mentioned' do
        UserMailer.should_receive(:mentioned).with(mentioned_user, comment).and_return(mailer)
      end
    end

    context 'mentioned user is comment author' do
      let(:mentioned_user) { comment_author }
      it 'does not notify the user' do
        event.should_not_receive(:notify!)
      end
    end
  end

  describe "send_new_vote_notifications!" do
    let(:motion_author) { stub(:motion_author) }
    let(:discussion_author) { stub(:discussion_author) }

    before do
      user = stub(:user)
      discussion = create :discussion
      @comment = create :comment
      discussion.add_comment(user, @comment)
      @event = Event.create!(:kind => "new_comment", :eventable => @comment,
                      :discussion_id => @comment.discussion.id)
      @event.stub(:notify!)
    end

    after do
      @event.send_new_vote_notifications!(vote)
    end

    context 'voter is not the motion author but is the discussion author' do
      let(:vote) { stub(:vote,
                  user: discussion_author,
                  motion_author: motion_author,
                  discussion_author: discussion_author) }
      it 'notifies the motion author' do
        @event.should_receive(:notify!).once.with(motion_author)
      end
    end
    context 'voter is not the discussion author but is the motion author' do
      let(:vote) { stub(:vote,
            user: motion_author,
            motion_author: motion_author,
            discussion_author: discussion_author) }
      it 'notifies the discussion author' do
        @event.should_receive(:notify!).once.with(discussion_author)
      end
    end
    context 'voter is neither the discussion author nor the discussion author' do
      let(:vote) { stub(:vote,
            user: user,
            motion_author: motion_author,
            discussion_author: discussion_author) }
      it 'notifies the discussion author' do
        @event.should_receive(:notify!).with(discussion_author)
      end
      it 'notifies the motion author' do
        @event.should_receive(:notify!).with(motion_author)
      end
    end
    context 'voter is the discussion author and the discussion author' do
      let(:vote) { stub(:vote,
            user: user,
            motion_author: user,
            discussion_author: user) }
      it 'notifies the discussion author' do
        @event.should_not_receive(:notify!)
      end
      it 'notifies the motion author' do
        @event.should_not_receive(:notify!)
      end
    end
  end

  describe "send_new_comment_notifications!" do
    before do
      user = stub(:user)
      discussion = create :discussion
      @comment = create :comment
      discussion.add_comment(user, @comment)
      @event = Event.create!(:kind => "new_comment", :eventable => @comment,
                      :discussion_id => @comment.discussion.id)

      @mentioned_user = stub(:user)
      @non_mentioned_user = stub(:user)
      @comment.stub(:mentioned_group_members).and_return([@mentioned_user])
      @comment.stub(:other_discussion_participants).and_return([@non_mentioned_user])
      @event.stub(:notify!)
      Event.stub(:user_mentioned!)
    end

    after do
      @event.send_new_comment_notifications!(@comment)
    end

    it 'fires a user_mentioned! event for each mentioned group member' do
      Event.should_receive(:user_mentioned!).with(@comment, @mentioned_user)
    end

    it 'calls event.notify! for each non mentioned group member' do
      @event.should_receive(:notify!).with(@non_mentioned_user)
    end
  end
end
