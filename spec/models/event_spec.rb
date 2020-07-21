require 'rails_helper'

# test emails and notifications being sent by events
describe Event do
  let(:all_emails_disabled) { {email_when_proposal_closing_soon: false} }
  let(:user_left_group) { create :user, all_emails_disabled }
  let(:user_thread_loud) { create :user, all_emails_disabled }
  let(:user_thread_normal) { create :user, all_emails_disabled }
  let(:user_thread_quiet) { create :user, all_emails_disabled }
  let(:user_thread_mute) { create :user, all_emails_disabled }
  let(:user_membership_loud) { create :user, all_emails_disabled }
  let(:user_membership_normal) { create :user, all_emails_disabled }
  let(:user_membership_quiet) { create :user, all_emails_disabled }
  let(:user_membership_mute) { create :user, all_emails_disabled }
  let(:user_motion_closing_soon) { create :user, all_emails_disabled.merge(email_when_proposal_closing_soon: true) }
  let(:user_mentioned) { create :user }
  let(:user_mentioned_text) { "Hello @#{user_mentioned.username}" }
  let(:user_unsubscribed) { create :user }

  let(:author) { create :user }
  let(:discussion) { create :discussion, description: user_mentioned_text, author: author }
  let(:mentioned_user) {create :user, username: 'sam', email_when_mentioned: true }
  let(:parent_comment) { create :comment, discussion: discussion}
  let(:comment) { create :comment, parent: parent_comment, discussion: discussion, body: 'hey @sam' }
  let(:poll) { create :poll, discussion: discussion, details: user_mentioned_text, author: author }
  let(:outcome) { create :outcome, poll: poll, statement: user_mentioned_text, author: author }
  let!(:markdown_webhook) { create(:webhook, group: discussion.group, format: 'markdown') }
  let!(:slack_webhook) { create(:webhook, group: discussion.group, format: 'slack') }
  let!(:microsoft_webhook) { create(:webhook, group: discussion.group, format: 'microsoft') }

  def emails_sent
    ActionMailer::Base.deliveries.count
  end

  before do
    discussion.group.add_member! author
    ActionMailer::Base.deliveries = []
    parent_comment
    DiscussionService.create(discussion: discussion, actor: discussion.author)
    discussion.group.add_member!(mentioned_user)
    discussion.group.add_member!(parent_comment.author)

    m = discussion.group.add_member!(user_left_group)
    DiscussionReader.for(discussion: discussion, user: user_left_group).set_volume! :loud
    m.destroy

    discussion.group.add_member!(user_thread_loud).set_volume! :mute
    discussion.group.add_member!(user_thread_normal).set_volume! :mute
    discussion.group.add_member!(user_thread_quiet).set_volume! :mute
    discussion.group.add_member!(user_thread_mute).set_volume! :mute
    discussion.group.add_member!(user_mentioned).set_volume! :mute
    discussion.group.add_member!(user_unsubscribed).set_volume! :mute

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

    poll.save

    # create an unsubscription for a poll user
    poll.poll_unsubscriptions.create(user: user_unsubscribed)
  end

  it 'new_comment' do
    Events::NewComment.publish!(parent_comment)
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
      # once for the group, once for the user notification
      Events::NewComment.publish!(parent_comment)
      expect(MessageChannelService).to receive(:publish_model).twice

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

  describe 'new_discussion' do
    it 'notifies mentioned users' do
      expect { Events::NewDiscussion.publish!(discussion) }.to change { emails_sent }.by(1) # (the mentioned user)
      expect(Events::UserMentioned.last.custom_fields['user_ids']).to include user_mentioned.id
    end
  end

  describe 'poll_created' do
    it 'notifies mentioned users' do
      expect { Events::PollCreated.publish!(poll, poll.author) }.to change { emails_sent }.by(1) # (the mentioned user)
      expect(Events::UserMentioned.last.custom_fields['user_ids']).to include user_mentioned.id
    end

    it 'notifies webhook if one exists' do
      Events::PollCreated.publish!(poll, poll.author)
      expect(WebMock).to have_requested(:post, markdown_webhook.url).at_least_once
    end
  end

  describe 'poll_edited' do
    it 'notifies mentioned users' do
      Events::PollCreated.publish!(poll, poll.author)
      poll.update(details: "#{poll.details} and @#{user_thread_loud.username}")
      expect { Events::PollEdited.publish!(poll, poll.author) }.to change { Events::UserMentioned.where(kind: :user_mentioned).count }.by(1) # (the newly mentioned user)
      expect(Events::UserMentioned.last.custom_fields['user_ids']).to include user_thread_loud.id
    end
  end

  describe 'poll_closing_soon' do
    describe 'voters_review_responses' do
      it 'should notify previously notified users when voters_review_responses is true' do
        poll = create(:poll_proposal, discussion: discussion)
        stances = [
          create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud),
          create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_normal)
        ]

        Events::PollAnnounced.publish!(poll, poll.author, stances)

        expect { Events::PollClosingSoon.publish!(poll) }.to change { emails_sent }


        notified_users = Events::PollClosingSoon.last.send(:notification_recipients)
        notified_users.should include user_thread_loud
        notified_users.should include user_thread_normal
        notified_users.should_not include user_thread_quiet
        notified_users.should_not include user_membership_quiet
        notified_users.should_not include user_thread_quiet
        notified_users.should_not include user_membership_mute
        notified_users.should_not include user_thread_mute
        notified_users.should_not include user_unsubscribed
        notified_users.should_not include poll.author

        emailed_users = Events::PollClosingSoon.last.send(:email_recipients)
        emailed_users.should include user_thread_loud
        emailed_users.should include user_thread_normal
        emailed_users.should_not include user_membership_quiet
        emailed_users.should_not include user_thread_quiet
        emailed_users.should_not include user_membership_mute
        emailed_users.should_not include user_thread_mute
        emailed_users.should_not include user_unsubscribed
        emailed_users.should_not include poll.author
      end

      it 'should notify previously notified users who have not participated when voters_review_responses is false' do
        # a loud user participates, so they dont get a closing soon announcement
        stances = [
          create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud),
          create(:stance, poll: poll, participant: user_thread_normal)
        ]

        # quiet user who has been announced to before
        Events::PollAnnounced.publish!(poll, poll.author, stances)

        expect { Events::PollClosingSoon.publish!(poll) }.to change { emails_sent }

        notified_users = Events::PollClosingSoon.last.send(:notification_recipients)
        notified_users.should_not include user_thread_loud
        notified_users.should include user_thread_normal
        notified_users.should_not include user_thread_quiet

        emailed_users = Events::PollClosingSoon.last.send(:email_recipients)
        emailed_users.should_not include user_thread_loud
        emailed_users.should include user_thread_normal
        emailed_users.should_not include user_thread_quiet
      end
    end
  end

  describe 'poll_expired' do
    it 'notifies the author' do
      expect { Events::PollExpired.publish!(poll) }.to change { emails_sent } # sends an email to the author

      notification_users = Events::PollExpired.last.send(:notification_recipients)
      expect(notification_users).to be_empty
      expect(notification_users).to_not include poll.author
      n = Notification.last
      expect(n.user).to eq poll.author
      expect(n.kind).to eq 'poll_expired'
    end
  end

  describe 'outcome_created' do
    let(:poll_meeting) { create :poll_meeting, discussion: discussion }

    before do
      outcome.update(poll: poll_meeting, calendar_invite: "SOME_EVENT_INFO")
    end

    it 'notifies mentioned users and the author' do
      expect { Events::OutcomeCreated.publish!(outcome) }.to change { emails_sent }.by(2) # mentioned user and the author
      expect(Events::UserMentioned.last.custom_fields['user_ids']).to include user_mentioned.id
      recipients = ActionMailer::Base.deliveries.map(&:to).flatten
      expect(recipients).to include user_mentioned.email
      expect(recipients).to include outcome.author.email
    end
  end

  describe 'stance_created' do
    let(:stance) { create :stance, poll: poll }

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

    it 'does not notify deactivated users' do
      poll.author.update(deactivated_at: 1.day.ago)
      expect { Events::StanceCreated.publish!(stance) }.to_not change { emails_sent }
      email_users = Events::StanceCreated.last.send(:email_recipients)
      expect(email_users).to be_empty
    end
  end

  describe 'announcement_created' do
    let(:poll) { create :poll, discussion: discussion }
    let(:poll_meeting) { create :poll_meeting, discussion: discussion }
    let(:outcome) { create :outcome, poll: poll_meeting }

    def stance_for(user)
      Stance.create(participant: user, poll: poll)
    end

    it 'does not email people with thread quiet' do
      expect {
        Events::PollAnnounced.publish!(poll, poll.author, [stance_for(user_thread_quiet)])
      }.to_not change { emails_sent }
    end

    it 'does not email people with group quiet' do
      expect {
        Events::PollAnnounced.publish!(poll, poll.author, [stance_for(user_membership_quiet)])
      }.to_not change { emails_sent }
    end

    it 'sends invitations' do
      expect {
        Events::PollAnnounced.publish!(poll, poll.author, [stance_for(user_thread_normal)])
      }.to change { emails_sent }.by(1)
    end

    it 'notifies the author if the eventable is an appropriate outcome' do
      expect {
        Events::OutcomeAnnounced.publish!(outcome, poll.author, [user_thread_normal])
      }.to change { emails_sent }.by(1)
    end

    it 'can send an ical attachment with an outcome' do
      outcome.update(poll: poll_meeting, calendar_invite: "SOME_EVENT_INFO")
      expect {
        Events::OutcomeAnnounced.publish!(outcome, poll.author, [user_thread_normal])
      }.to change { emails_sent }
      mail = ActionMailer::Base.deliveries.last
      expect(mail.attachments).to have(1).attachment
      expect(mail.attachments.first).to be_a Mail::Part
      expect(mail.attachments.first.content_type).to match /text\/calendar/
      expect(mail.attachments.first.filename).to eq 'meeting.ics'
    end
  end
end
