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

  let(:discussion) { create :discussion, description: user_mentioned_text }
  let(:mentioned_user) {create :user, username: 'sam', email_when_mentioned: true }
  let(:parent_comment) { create :comment, discussion: discussion}
  let(:comment) { create :comment, parent: parent_comment, discussion: discussion, body: 'hey @sam' }
  let(:poll) { create :poll, discussion: discussion, details: user_mentioned_text }
  let(:outcome) { create :outcome, poll: poll, statement: user_mentioned_text }

  let(:guest_user) { create :user }

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

    # add the loomio group community to poll
    poll.save

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

  it 'comment_edited' do
    comment.body = user_mentioned_text
    expect { Events::CommentEdited.publish!(comment, comment.author) }.to change { Event.where(kind: :user_mentioned).count }.by(1)
    expect { Events::CommentEdited.publish!(comment, comment.author) }.to_not change { Event.where(kind: :user_mentioned).count }
  end

  describe 'user_mentioned' do
    it 'notifies the mentioned user' do
      CommentService.create(comment: comment, actor: comment.author)
      event = Events::UserMentioned.find_by(kind: :user_mentioned)
      expect(event.eventable).to eq comment
      email_users = event.send(:email_recipients)
      expect(email_users.length).to eq 1
      expect(email_users).to include mentioned_user

      notification_users = event.send(:notification_recipients)
      expect(notification_users.length).to eq 1
      expect(notification_users).to include mentioned_user
    end
  end

  it 'new_discussion' do
    discussion.make_announcement = true
    expect { Events::NewDiscussion.publish!(discussion) }.to change { emails_sent }
    email_users = Events::NewDiscussion.find_by(kind: :new_discussion).send(:email_recipients)
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

  describe 'poll_created' do
    it 'sends notifications specified by the author' do

      # NB these are specified by the author, but will come in with these as the default
      poll.notified = [
        build(:notified_group, model: discussion.group).as_json.merge(notified_ids: [
          user_membership_loud.id,
          user_thread_loud.id,
          user_membership_normal.id,
          user_thread_normal.id,
          user_membership_quiet.id,
          user_thread_quiet.id,
          user_membership_mute.id,
          user_thread_mute.id
        ])
      ]

      expect { @event = Events::PollCreated.publish!(poll, poll.author) }.to change { emails_sent }
      email_users = @event.send(:email_recipients)
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

      notification_users = @event.send(:notification_recipients)
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
      expect { Events::PollCreated.publish!(poll, poll.author) }.to change { Event.where(kind: :user_mentioned).count }.by(1)
      expect(User.mentioned_in(poll)).to include user_mentioned
    end
  end

  describe 'poll_edited' do
    it 'makes an announcement to participants' do
      create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
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
    describe 'voters_review_responses', focus: true do

      def build_poll_closing_soon(poll_type)
        @poll = build(:"poll_#{poll_type}", discussion: discussion)
        @poll.notified = [
          build(:notified_group, model: discussion.group).as_json.merge(notified_ids: [
            user_thread_loud.id,
            user_thread_normal.id
          ]).as_json,
          build(:notified_user, model: user_left_group).as_json,
          build(:notified_invitation, model: "test@test.com").as_json
        ]
        PollService.create(poll: @poll, actor: @poll.group.admins.first)
        create(:stance, poll: @poll, choice: @poll.poll_options.first.name, participant: user_thread_quiet)
      end

      it 'true' do
        build_poll_closing_soon(:proposal)
        expect { @event = Events::PollClosingSoon.publish!(@poll) }.to change { emails_sent }

        notified_users = @event.send(:notification_recipients)
        notified_users.should include user_thread_loud
        notified_users.should include user_thread_normal
        notified_users.should include user_left_group # because they were added as a guest
        notified_users.should include user_thread_quiet # because they voted
        notified_users.should_not include user_unsubscribed

        emailed_users = @event.send(:email_recipients)
        emailed_users.should include user_thread_loud
        emailed_users.should include user_thread_normal
        emailed_users.should include user_left_group # because they were added as a guest
        emailed_users.should include user_thread_quiet # because they voted
        emailed_users.should_not include user_unsubscribed
      end

      it 'false' do
        build_poll_closing_soon(:meeting)
        expect { @event = Events::PollClosingSoon.publish!(@poll) }.to change { emails_sent }

        notified_users = @event.send(:notification_recipients)
        notified_users.should include user_thread_loud
        notified_users.should include user_thread_normal
        notified_users.should include user_left_group # because they were added as a guest
        notified_users.should_not include user_thread_quiet # because they voted
        notified_users.should_not include user_unsubscribed

        emailed_users = @event.send(:email_recipients)
        emailed_users.should include user_thread_loud
        emailed_users.should include user_thread_normal
        emailed_users.should include user_left_group # because they were added as a guest
        emailed_users.should_not include user_thread_quiet # because they voted
        emailed_users.should_not include user_unsubscribed
      end
    end

    it 'makes an announcement' do
      # NB these are specified by the author, but will come in with these as the default
      poll.notified = [
        build(:notified_group, model: discussion.group).as_json.merge(notified_ids: [
          user_membership_loud.id,
          user_thread_loud.id,
          user_membership_normal.id,
          user_thread_normal.id,
          user_membership_quiet.id,
          user_thread_quiet.id,
          user_membership_mute.id,
          user_thread_mute.id
        ])
      ]

      Events::PollCreated.publish!(poll, poll.author)

      expect { @event = Events::PollClosingSoon.publish!(poll) }.to change { emails_sent }
      email_users = @event.send(:email_recipients)
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

      notification_users = @event.send(:notification_recipients)
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
      expect(email_users.length).to eq 1
      expect(email_users).to include poll.author

      notification_users = Events::PollExpired.last.send(:notification_recipients)
      expect(notification_users).to include poll.author
      n = Notification.last
      expect(n.user).to eq poll.author
      expect(n.kind).to eq 'poll_expired'
    end

    it 'does not notify loomio helper bot' do
      poll.author = User.helper_bot
      expect { Events::PollExpired.publish!(poll) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'notifies everyone if announcement' do

      # NB these are specified by the author, but will come in with these as the default
      poll.notified = [
        build(:notified_group, model: discussion.group).as_json.merge(notified_ids: [
          user_membership_loud.id,
          user_thread_loud.id,
          user_membership_normal.id,
          user_thread_normal.id,
          user_membership_quiet.id,
          user_thread_quiet.id,
          user_membership_mute.id,
          user_thread_mute.id
        ])
      ]

      Events::PollCreated.publish!(poll, poll.author)
      @event = Events::PollExpired.publish!(poll)

      email_users = @event.send(:email_recipients)
      email_users.should     include user_thread_loud
      email_users.should     include user_membership_loud

      email_users.should     include user_membership_normal
      email_users.should     include user_thread_normal

      email_users.should_not include user_membership_quiet
      email_users.should_not include user_thread_quiet

      email_users.should_not include user_membership_mute
      email_users.should_not include user_thread_mute
      email_users.should_not include user_unsubscribed
      email_users.should include poll.author # notify the author of poll expiry

      notification_users = @event.send(:notification_recipients)
      notification_users.should     include user_thread_loud
      notification_users.should     include user_membership_loud

      notification_users.should     include user_membership_normal
      notification_users.should     include user_thread_normal

      notification_users.should     include user_membership_quiet
      notification_users.should     include user_thread_quiet

      notification_users.should     include user_membership_mute
      notification_users.should     include user_thread_mute
      notification_users.should include poll.author
    end
  end

  describe 'poll_option_added' do
    before do
      poll.update(voter_can_add_options: true)
      poll.guest_group.add_member! guest_user
    end

    it 'makes an announcement to participants' do
      create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
      poll.make_announcement = true
      guest_stance = create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: guest_user)
      expect { Events::PollOptionAdded.publish!(poll, poll.author, ["new_option"]) }.to change { emails_sent }
      email_users = Events::PollOptionAdded.last.send(:email_recipients)
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

      email_users.should include guest_user

      notification_users = Events::PollOptionAdded.last.send(:notification_recipients)
      notification_users.should     include user_thread_loud
      notification_users.should_not include user_membership_loud

      notification_users.should_not include user_membership_normal
      notification_users.should_not include user_thread_normal

      notification_users.should_not include user_membership_quiet
      notification_users.should_not include user_thread_quiet

      notification_users.should_not include user_membership_mute
      notification_users.should_not include user_thread_mute
      notification_users.should_not include poll.author

      notification_users.should include guest_user
    end

    it 'does not make an announcement' do
      event = Events::PollOptionAdded.publish!(poll, poll.author, ["new_option"])
      expect(event.send(:email_recipients)).to be_empty
      expect(event.send(:notification_recipients)).to be_empty
    end
  end

  describe 'outcome_created' do
    let(:poll_meeting) { create :poll_meeting, discussion: discussion }

    before do
      poll_meeting.guest_group.add_member! guest_user
      poll_meeting.poll_unsubscriptions.create(user: user_unsubscribed)
      outcome.update(poll: poll_meeting, calendar_invite: "SOME_EVENT_INFO")
    end

    it 'makes an announcement' do
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

      email_users.should     include guest_user

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

      notification_users.should     include guest_user

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

    it 'can send an ical attachment' do
      outcome.update(poll: poll_meeting, calendar_invite: "SOME_EVENT_INFO")
      outcome.make_announcement = true
      expect { Events::OutcomeCreated.publish!(outcome) }.to change { emails_sent }
      mail = ActionMailer::Base.deliveries.last
      expect(mail.attachments).to have(1).attachment
      expect(mail.attachments.first).to be_a Mail::Part
      expect(mail.attachments.first.content_type).to match /text\/calendar/
      expect(mail.attachments.first.filename).to eq 'meeting.ics'
    end

    it 'sends an email to the author if author_receives_outcome is true' do
      outcome.update(poll: poll_meeting, calendar_invite: "SOME_EVENT_INFO")
      outcome.make_announcement = true
      Events::OutcomeCreated.publish!(outcome)
      expect(ActionMailer::Base.deliveries.map(&:to).flatten).to include outcome.author.email
    end
  end

  describe 'invitation_accepted' do
    let(:poll) { create :poll }
    let(:guest_membership) { create :membership, group: poll.guest_group }
    let(:formal_membership) { create :membership, group: create(:formal_group) }

    it 'links to a group for a formal group invitation' do
      event = Events::InvitationAccepted.publish!(guest_membership)
      expect(event.send(:notification_url)).to match "p/#{poll.key}"
      expect(event.send(:notification_translation_title)).to eq poll.title
    end

    it 'links to an invitation target for a guest group invitation' do
      event = Events::InvitationAccepted.publish!(formal_membership)
      expect(event.send(:notification_url)).to match "g/#{formal_membership.group.key}"
      expect(event.send(:notification_translation_title)).to eq formal_membership.group.full_name
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

    it 'does not notify deactivated users' do
      poll.author.update(deactivated_at: 1.day.ago)
      expect { Events::StanceCreated.publish!(stance) }.to_not change { emails_sent }
      email_users = Events::StanceCreated.last.send(:email_recipients)
      expect(email_users).to be_empty
    end
  end
end
