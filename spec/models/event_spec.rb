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
  let(:user_unsubscribed) { FactoryGirl.create :user }

  let(:discussion) { FactoryGirl.create :discussion, description: user_mentioned_text }
  let(:mentioned_user) {FactoryGirl.create :user, username: 'sam', email_when_mentioned: true }
  let(:parent_comment) { FactoryGirl.create :comment, discussion: discussion}
  let(:comment) { FactoryGirl.create :comment, parent: parent_comment, discussion: discussion, body: 'hey @sam' }
  let(:motion) { FactoryGirl.create :motion, discussion: discussion, description: user_mentioned_text }
  let(:vote) { FactoryGirl.create :vote, motion: motion }
  let(:poll) { FactoryGirl.create :poll, discussion: discussion, details: user_mentioned_text }
  let(:outcome) { FactoryGirl.create :outcome, poll: poll, statement: user_mentioned_text }

  let(:visitor) { FactoryGirl.create :visitor, community: poll.community_of_type(:email, build: true) }

  def emails_sent
    ActionMailer::Base.deliveries.count
  end

  before do
    ActionMailer::Base.deliveries = []
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
    discussion.group.add_member!(user_unsubscribed)

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

    # create an unsubscription for a poll user
    poll.poll_unsubscriptions.create(user: user_unsubscribed)
  end

  it 'new_comment' do
    expect { Events::NewComment.publish!(comment) }.to change { emails_sent }
    email_users = Events::NewComment.last.send(:email_recipients)
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
    expect { Events::NewVote.publish!(vote) }.to change { emails_sent }
    email_users = Events::NewVote.last.send(:email_recipients)
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
    expect { Events::NewDiscussion.publish!(discussion) }.to change { emails_sent }
    email_users = Events::NewDiscussion.last.send(:email_recipients)
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
    expect { Events::NewMotion.publish!(motion) }.to change { emails_sent }
    email_users = Events::NewMotion.last.send(:email_recipients)
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
    expect { Events::MotionClosingSoon.publish!(motion) }.to change { emails_sent }
    email_users = Events::MotionClosingSoon.last.send(:email_recipients)
    email_users.should     include user_thread_loud
    email_users.should     include user_membership_loud

    email_users.should     include user_membership_normal
    email_users.should     include user_thread_normal

    email_users.should_not include user_membership_quiet
    email_users.should_not include user_thread_quiet

    email_users.should_not include user_membership_mute
    email_users.should_not include user_thread_mute

    email_users.should     include user_motion_closing_soon

    notification_users = Events::MotionClosingSoon.last.send(:notification_recipients)
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
    expect { Events::MotionOutcomeCreated.publish!(motion) }.to change { emails_sent }
    email_users = Events::MotionOutcomeCreated.last.send(:email_recipients)
    email_users.should_not include user_thread_loud
    email_users.should     include user_membership_loud

    email_users.should     include user_membership_normal
    email_users.should     include user_thread_normal

    email_users.should_not include user_membership_quiet
    email_users.should_not include user_thread_quiet

    email_users.should_not include user_membership_mute
    email_users.should_not include user_thread_mute

    email_users.should_not include user_motion_closing_soon

    notification_users = Events::MotionOutcomeCreated.last.send(:notification_recipients)
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
    expect { Events::MotionClosed.publish!(motion) }.to change { emails_sent }
    email_users = Events::MotionClosed.last.send(:email_recipients)
    email_users.should     include user_thread_loud
    email_users.should     include user_membership_loud

    email_users.should     include user_membership_normal
    email_users.should     include user_thread_normal

    email_users.should_not include user_membership_quiet
    email_users.should_not include user_thread_quiet

    email_users.should_not include user_membership_mute
    email_users.should_not include user_thread_mute

    notification_users = Events::MotionClosed.last.send(:notification_recipients)
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
      expect { Events::PollCreated.publish!(poll) }.to change { emails_sent }
      email_users = Events::PollCreated.last.send(:email_recipients)
      email_users.should     include user_thread_loud
      email_users.should     include user_membership_loud

      email_users.should     include user_membership_normal
      email_users.should     include user_thread_normal

      email_users.should_not include user_membership_quiet
      email_users.should_not include user_thread_quiet

      email_users.should_not include user_membership_mute
      email_users.should_not include user_thread_mute
      email_users.should_not include user_unsubscribed
      email_users.should_not include poll.author

      notification_users = Events::PollCreated.last.send(:notification_recipients)
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
      expect { Events::PollCreated.publish!(poll) }.to change { emails_sent }
      email_users = Events::PollCreated.last.send(:email_recipients)
      expect(email_users.length).to eq 1
      expect(email_users).to include user_mentioned

      notification_users = Events::PollCreated.last.send(:notification_recipients)
      expect(notification_users.length).to eq 1
      expect(notification_users).to include user_mentioned
    end
  end

  describe 'poll_edited' do
    it 'makes an announcement to participants' do
      FactoryGirl.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
      expect { Events::PollEdited.publish!(poll.versions.last, poll.author, true) }.to change { emails_sent }
      email_users = Events::PollEdited.last.send(:email_recipients)
      email_users.should      include user_thread_loud
      email_users.should_not  include user_membership_loud

      email_users.should_not  include user_membership_normal
      email_users.should_not  include user_thread_normal

      email_users.should_not include user_membership_quiet
      email_users.should_not include user_thread_quiet

      email_users.should_not include user_membership_mute
      email_users.should_not include user_thread_mute
      email_users.should_not include user_unsubscribed
      email_users.should_not include poll.author

      notification_users = Events::PollEdited.last.send(:notification_recipients)
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
      expect { Events::PollEdited.publish!(poll.versions.last, poll.author) }.to change { emails_sent }
      email_users = Events::PollEdited.last.send(:email_recipients)
      expect(email_users.length).to eq 1
      expect(email_users).to include user_mentioned

      notification_users = Events::PollEdited.last.send(:notification_recipients)
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
        expect { Events::PollClosingSoon.publish!(poll) }.to change { emails_sent }

        notified_users = Events::PollClosingSoon.last.send(:notification_recipients)
        notified_users.should include user_thread_loud
        notified_users.should include user_thread_normal

        emailed_users = Events::PollClosingSoon.last.send(:email_recipients)
        emailed_users.should include user_thread_loud
        emailed_users.should include user_thread_normal
      end

      it 'false' do
        Event.create(kind: 'poll_created', announcement: true, eventable: poll)
        FactoryGirl.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
        expect { Events::PollClosingSoon.publish!(poll) }.to change { emails_sent }

        notified_users = Events::PollClosingSoon.last.send(:notification_recipients)
        notified_users.should_not include user_thread_loud
        notified_users.should include user_thread_normal

        emailed_users = Events::PollClosingSoon.last.send(:email_recipients)
        emailed_users.should_not include user_thread_loud
        emailed_users.should include user_thread_normal
      end

      it 'deals with visitors' do
        poll = FactoryGirl.create(:poll, discussion: discussion)
        Event.create(kind: 'poll_created', announcement: true, eventable: poll)
        FactoryGirl.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: visitor)
        FactoryGirl.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
        Events::PollClosingSoon.publish!(poll)

        notified_users = Events::PollClosingSoon.last.send(:notification_recipients)
        notified_users.should_not include user_thread_loud
        notified_users.should include user_thread_normal
      end
    end

    it 'makes an announcement' do
      Event.create(kind: 'poll_created', announcement: true, eventable: poll)
      expect { Events::PollClosingSoon.publish!(poll) }.to change { emails_sent }
      email_users = Events::PollClosingSoon.last.send(:email_recipients)
      email_users.should     include user_thread_loud
      email_users.should     include user_membership_loud

      email_users.should     include user_membership_normal
      email_users.should     include user_thread_normal

      email_users.should_not include user_membership_quiet
      email_users.should_not include user_thread_quiet

      email_users.should_not include user_membership_mute
      email_users.should_not include user_thread_mute
      email_users.should_not include user_unsubscribed
      email_users.should_not include poll.author

      notification_users = Events::PollClosingSoon.last.send(:notification_recipients)
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
      Events::PollClosingSoon.publish!(poll)
      email_users = Events::PollClosingSoon.last.send(:email_recipients)
      expect(email_users).to be_empty

      notification_users = Events::PollClosingSoon.last.send(:notification_recipients)
      expect(notification_users).to be_empty
    end

    it 'does not email helper bot' do
      poll.update(author: User.helper_bot)
      expect { Events::PollClosingSoon.publish!(poll) }.to_not change { emails_sent }
    end
  end

  describe 'poll_expired' do
    it 'notifies the author' do
      expect { Events::PollExpired.publish!(poll) }.to change { emails_sent }
      email_users = Events::PollExpired.last.send(:email_recipients)
      expect(email_users).to be_empty # the author is notified via a separate email

      notification_users = Events::PollExpired.last.send(:notification_recipients)
      expect(notification_users).to be_empty
      expect(notification_users).to_not include poll.author
      n = Notification.last
      expect(n.user).to eq poll.author
      expect(n.kind).to eq 'poll_expired'
    end

    it 'does not notify loomio helper bot' do
      poll.author = User.helper_bot
      expect { Events::PollExpired.publish!(poll) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'notifies everyone if announcement' do
      poll.make_announcement = true
      Events::PollCreated.publish!(poll)
      Events::PollExpired.publish!(poll)
      event = Events::PollExpired.last

      expect(event.announcement).to eq true
      email_users = event.send(:email_recipients)
      email_users.should     include user_thread_loud
      email_users.should     include user_membership_loud

      email_users.should     include user_membership_normal
      email_users.should     include user_thread_normal

      email_users.should_not include user_membership_quiet
      email_users.should_not include user_thread_quiet

      email_users.should_not include user_membership_mute
      email_users.should_not include user_thread_mute
      email_users.should_not include user_unsubscribed
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
  end

  describe 'outcome_created' do
    it 'makes an announcement' do
      visitor
      outcome.make_announcement = true
      expect { Events::OutcomeCreated.publish!(outcome) }.to change { emails_sent }
      email_users = Events::OutcomeCreated.last.send(:email_recipients)
      email_users.should     include user_thread_loud
      email_users.should     include user_membership_loud

      email_users.should     include user_membership_normal
      email_users.should     include user_thread_normal

      email_users.should_not include user_membership_quiet
      email_users.should_not include user_thread_quiet

      email_users.should_not include user_membership_mute
      email_users.should_not include user_thread_mute
      email_users.should_not include user_unsubscribed
      email_users.should_not include poll.author

      email_visitors = Events::OutcomeCreated.last.send(:email_visitors)
      email_visitors.should  include visitor

      notification_users = Events::OutcomeCreated.last.send(:notification_recipients)
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
      expect { Events::OutcomeCreated.publish!(outcome) }.to change { emails_sent }
      email_users = Events::OutcomeCreated.last.send(:email_recipients)
      expect(email_users.length).to eq 1
      expect(email_users).to include user_mentioned

      notification_users = Events::OutcomeCreated.last.send(:notification_recipients)
      expect(notification_users.length).to eq 1
      expect(notification_users).to include user_mentioned
    end
  end

  describe 'stance_created' do
    let(:stance) { build :stance, poll: poll }

    it 'notifies the author if notify_on_participate' do
      poll.update(notify_on_participate: true)
      expect { Events::StanceCreated.publish!(stance) }.to change { emails_sent }
      email_users = Events::StanceCreated.last.send(:email_recipients)
      expect(email_users.length).to eq 1
      expect(email_users).to include poll.author

      notification_users = Events::StanceCreated.last.send(:notification_recipients)
      expect(notification_users.length).to eq 1
      expect(notification_users).to include poll.author
    end

    it 'does not notify the author of her own stance' do
      poll.update(notify_on_participate: true)
      stance.update(participant: poll.author)
      expect { Events::StanceCreated.publish!(stance) }.to_not change { emails_sent }
      expect(Events::StanceCreated.last.send(:email_recipients)).to be_empty
      expect(Events::StanceCreated.last.send(:notification_recipients)).to be_empty
    end

    it 'does not notify the author if not notify_on_participate' do
      expect { Events::StanceCreated.publish!(stance) }.to_not change { emails_sent }
      expect(Events::StanceCreated.last.send(:email_recipients)).to be_empty
      expect(Events::StanceCreated.last.send(:notification_recipients)).to be_empty
    end

    it 'notifies the author for visitor participation' do
      visitor = create(:visitor)
      poll.update(notify_on_participate: true)
      stance.update(participant: visitor)
      expect { Events::StanceCreated.publish!(stance) }.to change { poll.author.notifications.count }.by(1)
      expect(Notification.last.actor).to eq visitor
    end
  end
end
