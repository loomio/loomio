require 'rails_helper'

# test emails and notifications being sent by events
describe Event do
  let(:all_emails_disabled) { {email_when_proposal_closing_soon: false} }
  let(:user_left_group) { FactoryBot.create :user, all_emails_disabled }
  let(:user_thread_loud) { FactoryBot.create :user, all_emails_disabled }
  let(:user_thread_normal) { FactoryBot.create :user, all_emails_disabled }
  let(:user_thread_quiet) { FactoryBot.create :user, all_emails_disabled }
  let(:user_thread_mute) { FactoryBot.create :user, all_emails_disabled }
  let(:user_membership_loud) { FactoryBot.create :user, all_emails_disabled }
  let(:user_membership_normal) { FactoryBot.create :user, all_emails_disabled }
  let(:user_membership_quiet) { FactoryBot.create :user, all_emails_disabled }
  let(:user_membership_mute) { FactoryBot.create :user, all_emails_disabled }
  let(:user_motion_closing_soon) { FactoryBot.create :user, all_emails_disabled.merge(email_when_proposal_closing_soon: true) }
  let(:user_mentioned) { FactoryBot.create :user }
  let(:user_mentioned_text) { "Hello @#{user_mentioned.username}" }
  let(:user_unsubscribed) { FactoryBot.create :user }

  let(:discussion) { FactoryBot.create :discussion, description: user_mentioned_text }
  let(:mentioned_user) {FactoryBot.create :user, username: 'sam', email_when_mentioned: true }
  let(:parent_comment) { FactoryBot.create :comment, discussion: discussion}
  let(:comment) { FactoryBot.create :comment, parent: parent_comment, discussion: discussion, body: 'hey @sam' }
  let(:poll) { FactoryBot.create :poll, discussion: discussion, details: user_mentioned_text }
  let(:outcome) { FactoryBot.create :outcome, poll: poll, statement: user_mentioned_text }

  let(:guest_user) { FactoryBot.create :user }

  def emails_sent
    ActionMailer::Base.deliveries.count
  end

  before do
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

  describe 'user_mentioned' do
    it 'notifies the mentioned user' do
      # once for the group, once for the user notification
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

  describe 'poll_created' do
    it 'makes an announcement' do
      poll.make_announcement = true
      expect { Events::PollCreated.publish!(poll, poll.author) }.to change { emails_sent }
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
      expect { Events::PollCreated.publish!(poll, poll.author) }.to change { emails_sent }
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
      FactoryBot.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
      expect { Events::PollEdited.publish!(poll, poll.author, true) }.to change { emails_sent }
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
      expect { Events::PollEdited.publish!(poll, poll.author) }.to change { emails_sent }
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
      it 'true' do
        poll = FactoryBot.build(:poll_proposal, discussion: discussion, make_announcement: true)
        PollService.create(poll: poll, actor: discussion.group.admins.first)
        FactoryBot.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
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
        FactoryBot.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
        expect { Events::PollClosingSoon.publish!(poll) }.to change { emails_sent }

        notified_users = Events::PollClosingSoon.last.send(:notification_recipients)
        notified_users.should_not include user_thread_loud
        notified_users.should include user_thread_normal

        emailed_users = Events::PollClosingSoon.last.send(:email_recipients)
        emailed_users.should_not include user_thread_loud
        emailed_users.should include user_thread_normal
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
      Events::PollCreated.publish!(poll, poll.author)
      event = Events::PollExpired.publish!(poll)

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

  describe 'poll_option_added' do
    before do
      poll.update(voter_can_add_options: true)
      poll.guest_group.add_member! guest_user
    end

    it 'makes an announcement to participants' do
      FactoryBot.create(:stance, poll: poll, choice: poll.poll_options.first.name, participant: user_thread_loud)
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

    it 'makes an announcement for a standalone' do
      poll    = create(:poll, group: nil)
      outcome = create(:outcome, poll: poll)
      stance  = create :stance, poll: poll

      expect { Events::OutcomeCreated.publish!(outcome) }.to change { emails_sent }
      email_users = Events::OutcomeCreated.last.send(:email_recipients)
      email_users.should      include stance.participant
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
