require 'rails_helper'

# test emails and notifications being sent by events
describe Event do
  let(:all_emails_disabled) { {email_when_proposal_closing_soon: false} }
  let(:user_left_group) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_thread_loud) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_thread_normal) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_thread_quiet) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_thread_mute) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_membership_loud) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_membership_normal) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_membership_quiet) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_membership_mute) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_motion_closing_soon) { FactoryGirl.create :user, all_emails_disabled.merge(email_when_proposal_closing_soon: true) }
  let(:user_mentioned) { FactoryGirl.create :user }
  let(:user_mentioned_text) { "Hello @#{user_mentioned.username}" }

  let(:discussion) { FactoryGirl.create :discussion, description: user_mentioned_text }
  let(:mentioned_user) {FactoryGirl.create :user, username: 'sam' }
  let(:parent_comment) { FactoryGirl.create :comment, discussion: discussion}
  let(:comment) { FactoryGirl.create :comment, parent: parent_comment, discussion: discussion, body: 'hey @sam' }
  let(:motion) { FactoryGirl.create :motion, discussion: discussion, description: user_mentioned_text }
  let(:vote) { FactoryGirl.create :vote, motion: motion }
  let(:poll) { FactoryGirl.create :poll, discussion: discussion, details: user_mentioned_text }
  let(:outcome) { FactoryGirl.create :outcome, poll: poll, statement: user_mentioned_text }

  before do
    parent_comment
    discussion.group.add_member!(mentioned_user)
    discussion.group.add_member!(parent_comment.author)

    m = discussion.group.add_member!(user_left_group)
    DiscussionReader.for(discussion: discussion, user: user_left_group).set_volume! :loud
    m.destroy

    discussion.group.add_member!(user_thread_loud).set_volume! :mute
    discussion.group.add_member!(user_thread_normal).set_volume! :mute
    discussion.group.add_member!(user_thread_quiet).set_volume! :mute
    discussion.group.add_member!(user_thread_mute).set_volume! :mute
    discussion.group.add_member!(user_mentioned)

    DiscussionReader.for(discussion: discussion, user: user_thread_loud).set_volume! :loud
    DiscussionReader.for(discussion: discussion, user: user_thread_normal).set_volume! :normal
    DiscussionReader.for(discussion: discussion, user: user_thread_quiet).set_volume! :quiet
    DiscussionReader.for(discussion: discussion, user: user_thread_mute).set_volume! :mute

    # set membership volume - email for new discussions and proposals
    discussion.group.add_member!(user_membership_loud).set_volume! :loud
    discussion.group.add_member!(user_membership_normal).set_volume! :normal
    discussion.group.add_member!(user_membership_quiet).set_volume! :quiet
    discussion.group.add_member!(user_membership_mute).set_volume! :mute

    # set email motion closing soon
    discussion.group.add_member!(user_motion_closing_soon).set_volume! :mute
  end

  it 'new_comment' do
    event = Events::NewComment.publish!(comment)
    email_users = event.send(:email_recipients)
    email_users.should     include user_thread_loud
    email_users.should     include user_membership_loud

    email_users.should_not include user_left_group

    email_users.should_not include user_membership_normal
    email_users.should_not include user_thread_normal

    email_users.should_not include user_membership_quiet
    email_users.should_not include user_thread_quiet

    email_users.should_not include user_membership_mute
    email_users.should_not include user_thread_mute

    email_users.should_not include comment.author
    email_users.should_not include mentioned_user
    email_users.should_not include comment.parent.author
  end

  describe 'user_mentioned' do
    it 'notifies the mentioned user' do
      CommentService.create(comment: comment, actor: comment.author)
      event = Events::UserMentioned.where(kind: :user_mentioned).last
      expect(event.eventable).to eq comment
      email_users = event.send(:email_recipients)
      expect(email_users.length).to eq 1
      expect(email_users).to include mentioned_user

      notification_users = event.send(:notification_recipients)
      expect(notification_users.length).to eq 1
      expect(notification_users).to include mentioned_user
    end
  end

  it 'new_vote' do
    email_users = Events::NewVote.publish!(vote).send(:email_recipients)
    email_users.should     include user_thread_loud
    email_users.should     include user_membership_loud

    email_users.should_not include user_membership_normal
    email_users.should_not include user_thread_normal

    email_users.should_not include user_membership_quiet
    email_users.should_not include user_thread_quiet

    email_users.should_not include user_membership_mute
    email_users.should_not include user_thread_mute

    email_users.should_not include vote.author
  end

  it 'new_discussion' do
    discussion.make_announcement = true
    email_users = Events::NewDiscussion.publish!(discussion).send(:email_recipients)
    email_users.should     include user_thread_loud
    email_users.should     include user_membership_loud

    email_users.should     include user_membership_normal
    email_users.should     include user_thread_normal

    email_users.should_not include user_membership_quiet
    email_users.should_not include user_thread_quiet

    email_users.should_not include user_membership_mute
    email_users.should_not include user_thread_mute

    email_users.should_not include discussion.author
    email_users.should_not include user_mentioned
  end

  it 'new_motion' do
    email_users = Events::NewMotion.publish!(motion).send(:email_recipients)
    email_users.should     include user_thread_loud
    email_users.should     include user_membership_loud

    email_users.should     include user_membership_normal
    email_users.should     include user_thread_normal

    email_users.should_not include user_membership_quiet
    email_users.should_not include user_thread_quiet

    email_users.should_not include user_membership_mute
    email_users.should_not include user_thread_mute

    email_users.should_not include motion.author
    email_users.should_not include user_mentioned
  end

  it 'motion_closing_soon' do
    event = Events::MotionClosingSoon.publish!(motion)
    email_users = event.send(:email_recipients)
    email_users.should     include user_thread_loud
    email_users.should     include user_membership_loud

    email_users.should     include user_membership_normal
    email_users.should     include user_thread_normal

    email_users.should_not include user_membership_quiet
    email_users.should_not include user_thread_quiet

    email_users.should_not include user_membership_mute
    email_users.should_not include user_thread_mute

    email_users.should     include user_motion_closing_soon

    notification_users = event.send(:notification_recipients)
    notification_users.should     include user_thread_loud
    notification_users.should     include user_membership_loud

    notification_users.should     include user_membership_normal
    notification_users.should     include user_thread_normal

    notification_users.should_not include user_membership_quiet
    notification_users.should_not include user_thread_quiet

    notification_users.should_not include user_membership_mute
    notification_users.should_not include user_thread_mute

    notification_users.should_not include user_motion_closing_soon
  end

  it 'motion_outcome' do
    motion.update(outcome_author: user_thread_loud)
    event = Events::MotionOutcomeCreated.publish!(motion)
    email_users = event.send(:email_recipients)
    email_users.should_not include user_thread_loud
    email_users.should     include user_membership_loud

    email_users.should     include user_membership_normal
    email_users.should     include user_thread_normal

    email_users.should_not include user_membership_quiet
    email_users.should_not include user_thread_quiet

    email_users.should_not include user_membership_mute
    email_users.should_not include user_thread_mute

    email_users.should_not include user_motion_closing_soon

    notification_users = event.send(:notification_recipients)
    notification_users.should_not include user_thread_loud
    notification_users.should     include user_membership_loud

    notification_users.should     include user_membership_normal
    notification_users.should     include user_thread_normal

    notification_users.should_not include user_membership_quiet
    notification_users.should_not include user_thread_quiet

    notification_users.should_not include user_membership_mute
    notification_users.should_not include user_thread_mute

    notification_users.should_not include user_motion_closing_soon
  end

  it 'motion_closed' do
    event = Events::MotionClosed.publish!(motion)
    email_users = event.send(:email_recipients)
    email_users.should     include user_thread_loud
    email_users.should     include user_membership_loud

    email_users.should     include user_membership_normal
    email_users.should     include user_thread_normal

    email_users.should_not include user_membership_quiet
    email_users.should_not include user_thread_quiet

    email_users.should_not include user_membership_mute
    email_users.should_not include user_thread_mute

    notification_users = event.send(:notification_recipients)
    notification_users.should_not include user_thread_loud
    notification_users.should_not include user_membership_loud

    notification_users.should_not include user_membership_normal
    notification_users.should_not include user_thread_normal

    notification_users.should_not include user_membership_quiet
    notification_users.should_not include user_thread_quiet

    notification_users.should_not include user_membership_mute
    notification_users.should_not include user_thread_mute
    notification_users.should     include motion.author
  end

  describe 'poll_created' do
    it 'makes an announcement' do
      poll.make_announcement = true
      event = Events::PollCreated.publish!(poll)
      email_users = event.send(:email_recipients)
      email_users.should     include user_thread_loud
      email_users.should     include user_membership_loud

      email_users.should     include user_membership_normal
      email_users.should     include user_thread_normal

      email_users.should_not include user_membership_quiet
      email_users.should_not include user_thread_quiet

      email_users.should_not include user_membership_mute
      email_users.should_not include user_thread_mute
      email_users.should_not include poll.author

      notification_users = event.send(:notification_recipients)
      notification_users.should     include user_thread_loud
      notification_users.should     include user_membership_loud

      notification_users.should     include user_membership_normal
      notification_users.should     include user_thread_normal

      notification_users.should     include user_membership_quiet
      notification_users.should     include user_thread_quiet

      notification_users.should     include user_membership_mute
      notification_users.should     include user_thread_mute
      notification_users.should_not include poll.author
    end

    it 'notifies mentioned users' do
      event = Events::PollCreated.publish!(poll)
      email_users = event.send(:email_recipients)
      expect(email_users.length).to eq 1
      expect(email_users).to include user_mentioned

      notification_users = event.send(:notification_recipients)
      expect(notification_users.length).to eq 1
      expect(notification_users).to include user_mentioned
    end
  end

  describe 'poll_edited' do
    it 'makes an announcement to participants' do
      FactoryGirl.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
      event = Events::PollEdited.publish!(poll.versions.last, poll.author, true)
      email_users = event.send(:email_recipients)
      email_users.should      include user_thread_loud
      email_users.should_not  include user_membership_loud

      email_users.should_not  include user_membership_normal
      email_users.should_not  include user_thread_normal

      email_users.should_not include user_membership_quiet
      email_users.should_not include user_thread_quiet

      email_users.should_not include user_membership_mute
      email_users.should_not include user_thread_mute
      email_users.should_not include poll.author

      notification_users = event.send(:notification_recipients)
      notification_users.should     include user_thread_loud
      notification_users.should_not include user_membership_loud

      notification_users.should_not include user_membership_normal
      notification_users.should_not include user_thread_normal

      notification_users.should_not include user_membership_quiet
      notification_users.should_not include user_thread_quiet

      notification_users.should_not include user_membership_mute
      notification_users.should_not include user_thread_mute
      notification_users.should_not include poll.author
    end

    it 'notifies mentioned users' do
      event = Events::PollEdited.publish!(poll.versions.last, poll.author)
      email_users = event.send(:email_recipients)
      expect(email_users.length).to eq 1
      expect(email_users).to include user_mentioned

      notification_users = event.send(:notification_recipients)
      expect(notification_users.length).to eq 1
      expect(notification_users).to include user_mentioned
    end
  end

  describe 'poll_closing_soon' do
    let(:visitor) { poll.community_of_type(:email, build: true).tap(&:save!).visitors.create(name: 'jimbo', email: 'helllloo@example.com')}
    describe 'voters_review_responses', focus: true do
      it 'true' do
        poll = FactoryGirl.create(:poll_proposal, discussion: discussion)
        Event.create(kind: 'poll_created', announcement: true, eventable: poll)
        FactoryGirl.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
        event = Events::PollClosingSoon.publish!(poll)

        notified_users = event.send(:notification_recipients)
        notified_users.should include user_thread_loud
        notified_users.should include user_thread_normal

        emailed_users = event.send(:email_recipients)
        emailed_users.should include user_thread_loud
        emailed_users.should include user_thread_normal
      end

      it 'false' do
        Event.create(kind: 'poll_created', announcement: true, eventable: poll)
        FactoryGirl.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
        event = Events::PollClosingSoon.publish!(poll)

        notified_users = event.send(:notification_recipients)
        notified_users.should_not include user_thread_loud
        notified_users.should include user_thread_normal

        emailed_users = event.send(:email_recipients)
        emailed_users.should_not include user_thread_loud
        emailed_users.should include user_thread_normal
      end

      it 'deals with visitors' do
        poll = FactoryGirl.create(:poll, discussion: discussion)
        Event.create(kind: 'poll_created', announcement: true, eventable: poll)
        FactoryGirl.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: visitor)
        FactoryGirl.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
        event = Events::PollClosingSoon.publish!(poll)

        notified_users = event.send(:notification_recipients)
        notified_users.should_not include user_thread_loud
        notified_users.should include user_thread_normal
      end
    end

    it 'makes an announcement' do
      Event.create(kind: 'poll_created', announcement: true, eventable: poll)
      event = Events::PollClosingSoon.publish!(poll)
      email_users = event.send(:email_recipients)
      email_users.should     include user_thread_loud
      email_users.should     include user_membership_loud

      email_users.should     include user_membership_normal
      email_users.should     include user_thread_normal

      email_users.should_not include user_membership_quiet
      email_users.should_not include user_thread_quiet

      email_users.should_not include user_membership_mute
      email_users.should_not include user_thread_mute
      email_users.should_not include poll.author

      notification_users = event.send(:notification_recipients)
      notification_users.should     include user_thread_loud
      notification_users.should     include user_membership_loud

      notification_users.should     include user_membership_normal
      notification_users.should     include user_thread_normal

      notification_users.should     include user_membership_quiet
      notification_users.should     include user_thread_quiet

      notification_users.should     include user_membership_mute
      notification_users.should     include user_thread_mute
      notification_users.should_not include poll.author
    end

    it 'does not notify when not an announcement' do
      event = Events::PollClosingSoon.publish!(poll)
      email_users = event.send(:email_recipients)
      expect(email_users).to be_empty

      notification_users = event.send(:notification_recipients)
      expect(notification_users).to be_empty
    end
  end

  describe 'poll_expired' do
    it 'notifies the author' do
      event = Events::PollExpired.publish!(poll)
      email_users = event.send(:email_recipients)
      expect(email_users.length).to eq 1
      expect(email_users).to include poll.author

      notification_users = event.send(:notification_recipients)
      expect(notification_users.length).to eq 1
      expect(notification_users).to include poll.author
    end
  end

  describe 'outcome_created' do
    it 'makes an announcement' do
      outcome.make_announcement = true
      event = Events::OutcomeCreated.publish!(outcome)
      email_users = event.send(:email_recipients)
      email_users.should     include user_thread_loud
      email_users.should     include user_membership_loud

      email_users.should     include user_membership_normal
      email_users.should     include user_thread_normal

      email_users.should_not include user_membership_quiet
      email_users.should_not include user_thread_quiet

      email_users.should_not include user_membership_mute
      email_users.should_not include user_thread_mute
      email_users.should_not include poll.author

      notification_users = event.send(:notification_recipients)
      notification_users.should     include user_thread_loud
      notification_users.should     include user_membership_loud

      notification_users.should     include user_membership_normal
      notification_users.should     include user_thread_normal

      notification_users.should     include user_membership_quiet
      notification_users.should     include user_thread_quiet

      notification_users.should     include user_membership_mute
      notification_users.should     include user_thread_mute
      notification_users.should_not include poll.author
    end

    it 'notifies mentioned users' do
      event = Events::OutcomeCreated.publish!(outcome)
      email_users = event.send(:email_recipients)
      expect(email_users.length).to eq 1
      expect(email_users).to include user_mentioned

      notification_users = event.send(:notification_recipients)
      expect(notification_users.length).to eq 1
      expect(notification_users).to include user_mentioned
    end
  end

end
