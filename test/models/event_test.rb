require 'test_helper'

class EventTest < ActiveSupport::TestCase
  ALL_EMAILS_DISABLED = { email_when_proposal_closing_soon: false }.freeze

  setup do
    @author = User.create!(name: "Author #{SecureRandom.hex(4)}", email: "evauthor_#{SecureRandom.hex(4)}@test.com", email_verified: true, **ALL_EMAILS_DISABLED)
    @group = Group.create!(name: "Event Group #{SecureRandom.hex(4)}", group_privacy: 'secret',
                           members_can_announce: true)
    @group.add_admin!(@author)

    @mentioned_user = User.create!(name: "mentioned", email: "mentioned_#{SecureRandom.hex(4)}@test.com",
                                   email_verified: true, username: "sam#{SecureRandom.hex(3)}")
    @user_mentioned_text = "Hello @#{@mentioned_user.username}"

    @discussion = Discussion.new(group: @group, title: "Event Test Discussion",
                                 description: @user_mentioned_text, description_format: 'md',
                                 private: true, author: @author)
    DiscussionService.create(discussion: @discussion, actor: @author)

    @group.add_member!(@mentioned_user)

    # Users with different volume settings
    @user_thread_loud = User.create!(name: "thread loud", email: "tloud_#{SecureRandom.hex(4)}@test.com", email_verified: true, **ALL_EMAILS_DISABLED)
    @user_thread_normal = User.create!(name: "thread normal", email: "tnorm_#{SecureRandom.hex(4)}@test.com", email_verified: true, **ALL_EMAILS_DISABLED)
    @user_thread_quiet = User.create!(name: "thread quiet", email: "tquiet_#{SecureRandom.hex(4)}@test.com", email_verified: true, **ALL_EMAILS_DISABLED)
    @user_thread_mute = User.create!(name: "thread mute", email: "tmute_#{SecureRandom.hex(4)}@test.com", email_verified: true, **ALL_EMAILS_DISABLED)
    @user_membership_loud = User.create!(name: "membership loud", email: "mloud_#{SecureRandom.hex(4)}@test.com", email_verified: true, **ALL_EMAILS_DISABLED)
    @user_membership_normal = User.create!(name: "membership normal", email: "mnorm_#{SecureRandom.hex(4)}@test.com", email_verified: true, **ALL_EMAILS_DISABLED)
    @user_membership_quiet = User.create!(name: "membership quiet", email: "mquiet_#{SecureRandom.hex(4)}@test.com", email_verified: true, **ALL_EMAILS_DISABLED)
    @user_membership_mute = User.create!(name: "membership mute", email: "mmute_#{SecureRandom.hex(4)}@test.com", email_verified: true, **ALL_EMAILS_DISABLED)
    @user_left_group = User.create!(name: "left group", email: "left_#{SecureRandom.hex(4)}@test.com", email_verified: true, **ALL_EMAILS_DISABLED)

    @parent_comment = Comment.new(discussion: @discussion, body: "Parent comment", author: @author)
    CommentService.create(comment: @parent_comment, actor: @author)

    # User who left group
    m = @group.add_member!(@user_left_group)
    DiscussionReader.for(discussion: @discussion, user: @user_left_group).set_email_volume!(:loud)
    m.destroy

    # Thread volume users (membership muted, thread overrides)
    @group.add_member!(@user_thread_loud).set_email_volume!(:mute)
    @group.add_member!(@user_thread_normal).set_email_volume!(:mute)
    @group.add_member!(@user_thread_quiet).set_email_volume!(:mute)
    @group.add_member!(@user_thread_mute).set_email_volume!(:mute)
    @group.membership_for(@mentioned_user).set_email_volume!(:mute)

    DiscussionReader.for(discussion: @discussion, user: @user_thread_loud).set_email_volume!(:loud)
    DiscussionReader.for(discussion: @discussion, user: @user_thread_normal).set_email_volume!(:normal)
    DiscussionReader.for(discussion: @discussion, user: @user_thread_quiet).set_email_volume!(:quiet)
    DiscussionReader.for(discussion: @discussion, user: @user_thread_mute).set_email_volume!(:mute)

    # Membership volume users
    @group.add_member!(@user_membership_loud).set_email_volume!(:loud)
    @group.add_member!(@user_membership_normal).set_email_volume!(:normal)
    @group.add_member!(@user_membership_quiet).set_email_volume!(:quiet)
    @group.add_member!(@user_membership_mute).set_email_volume!(:mute)

    # Webhook (created before poll so it's present when events fire)
    @webhook_url = "https://webhook-#{SecureRandom.hex(4)}.example.com/hook"
    WebMock.stub_request(:post, @webhook_url).to_return(status: 200)
    @webhook = Chatbot.create!(
      group: @group,
      author: @author,
      name: "Test Webhook",
      server: @webhook_url,
      webhook_kind: 'markdown',
      kind: 'webhook',
      event_kinds: %w[new_discussion discussion_edited poll_created poll_edited poll_closing_soon poll_expired poll_announced poll_reopened outcome_created]
    )

    # Create poll (without PollService.create to avoid publishing events/emails in setup)
    @poll = Poll.new(poll_type: 'proposal', title: "Event Poll",
                     poll_option_names: %w[agree disagree abstain],
                     closing_at: 1.day.from_now, opened_at: Time.now, author: @author,
                     discussion: @discussion, group: @group,
                     details: @user_mentioned_text, specified_voters_only: true)
    @poll.save!
    @poll.create_missing_created_event!

    ActionMailer::Base.deliveries.clear
  end

  test "new_comment sends emails to loud subscribers" do
    comment = Comment.new(discussion: @discussion, body: "hey @#{@mentioned_user.username}",
                          parent: @parent_comment, author: @author)
    CommentService.create(comment: comment, actor: @author)
    event = Events::NewComment.last
    subscribed = event.send(:subscribed_recipients)
    assert_includes subscribed, @user_thread_loud
    assert_includes subscribed, @user_membership_loud
    assert_not_includes subscribed, @user_left_group
    assert_not_includes subscribed, @user_membership_normal
    assert_not_includes subscribed, @user_thread_normal
    assert_not_includes subscribed, @user_membership_quiet
    assert_not_includes subscribed, @user_thread_quiet
    assert_not_includes subscribed, @user_membership_mute
    assert_not_includes subscribed, @user_thread_mute
  end

  test "user_mentioned notifies mentioned user" do
    comment = Comment.new(discussion: @discussion, body: "hey @#{@mentioned_user.username}",
                          parent: @parent_comment, author: @author)
    CommentService.create(comment: comment, actor: @author)
    event = Events::UserMentioned.where(kind: :user_mentioned).last
    assert_equal comment, event.eventable
    email_users = event.send(:email_recipients)
    assert_equal 1, email_users.length
    assert_includes email_users, @mentioned_user
    notification_users = event.send(:notification_recipients)
    assert_equal 1, notification_users.length
    assert_includes notification_users, @mentioned_user
  end

  test "new_discussion notifies mentioned users" do
    assert_difference -> { ActionMailer::Base.deliveries.count }, 3 do
      Events::NewDiscussion.publish!(discussion: @discussion)
    end
    assert_equal 1, @discussion.mentioned_users.length
    assert_equal 2, Events::NewDiscussion.last.subscribed_recipients.length
    assert_includes Events::UserMentioned.last.custom_fields['user_ids'], @mentioned_user.id
  end

  test "poll_created notifies mentioned users and loud subscribers" do
    assert_difference -> { ActionMailer::Base.deliveries.count }, 3 do
      Events::PollCreated.publish!(@poll, @poll.author)
    end
    assert_equal 1, @poll.mentioned_users.length
    assert_includes Events::UserMentioned.last.custom_fields['user_ids'], @mentioned_user.id
  end

  test "poll_created notifies webhook" do
    Events::PollCreated.publish!(@poll, @poll.author)
    assert_requested :post, @webhook_url, at_least_times: 1
  end

  test "poll_edited notifies newly mentioned users" do
    Events::PollCreated.publish!(@poll, @poll.author)
    @poll.update!(details: "#{@poll.details} and @#{@user_thread_loud.username}")
    assert_difference -> { Events::UserMentioned.where(kind: :user_mentioned).count }, 1 do
      Events::PollEdited.publish!(poll: @poll, actor: @poll.author)
    end
    assert_includes Events::UserMentioned.last.custom_fields['user_ids'], @user_thread_loud.id
  end

  test "poll_closing_soon notify_on_closing_soon voters" do
    @poll.update!(notify_on_closing_soon: 'voters')
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_loud, cast_at: Time.current)
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_normal, cast_at: Time.current)
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_quiet, email_volume: 'quiet', cast_at: Time.current)
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_mute, email_volume: 'mute', cast_at: Time.current)

    assert_difference -> { ActionMailer::Base.deliveries.count }, 2 do
      Events::PollClosingSoon.publish!(@poll)
    end

    notified = Events::PollClosingSoon.last.send(:notification_recipients)
    assert_includes notified, @user_thread_loud
    assert_includes notified, @user_thread_normal
    assert_includes notified, @user_thread_quiet
    assert_not_includes notified, @user_thread_mute
    assert_equal 3, notified.count

    emailed = Events::PollClosingSoon.last.send(:email_recipients)
    assert_includes emailed, @user_thread_loud
    assert_includes emailed, @user_thread_normal
    assert_not_includes emailed, @user_thread_quiet
    assert_not_includes emailed, @user_thread_mute
    assert_equal 2, emailed.count
  end

  test "poll_closing_soon notify_on_closing_soon undecided_voters" do
    @poll.update!(notify_on_closing_soon: 'undecided_voters')
    Stance.create!(poll: @poll, cast_at: Time.current, choice: 'Agree', participant: @user_thread_loud)
    Stance.create!(poll: @poll, participant: @user_thread_normal)

    assert_difference -> { ActionMailer::Base.deliveries.count } do
      Events::PollClosingSoon.publish!(@poll)
    end

    notified = Events::PollClosingSoon.last.send(:notification_recipients)
    assert_not_includes notified, @user_thread_loud
    assert_includes notified, @user_thread_normal
    assert_not_includes notified, @user_thread_quiet

    emailed = Events::PollClosingSoon.last.send(:email_recipients)
    assert_not_includes emailed, @user_thread_loud
    assert_includes emailed, @user_thread_normal
    assert_not_includes emailed, @user_thread_quiet
  end

  test "poll_closing_soon notify_on_closing_soon author" do
    @poll.update!(notify_on_closing_soon: 'author')
    assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
      Events::PollClosingSoon.publish!(@poll)
    end
    assert Events::PollClosingSoon.last.send(:notify_author?)
  end

  test "poll_closing_soon notify_on_closing_soon nobody" do
    @poll.update!(notify_on_closing_soon: 'nobody')
    Stance.create!(poll: @poll, cast_at: Time.current, choice: 'Agree', participant: @user_thread_loud)
    Stance.create!(poll: @poll, participant: @user_thread_normal)

    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      Events::PollClosingSoon.publish!(@poll)
    end

    assert_equal 0, Events::PollClosingSoon.last.send(:notification_recipients).count
    assert_equal 0, Events::PollClosingSoon.last.send(:email_recipients).count
  end

  test "poll_expired notifies the author" do
    assert_difference -> { ActionMailer::Base.deliveries.count } do
      Events::PollExpired.publish!(@poll)
    end
    notification_users = Events::PollExpired.last.send(:notification_recipients)
    assert notification_users.empty?
    n = Notification.last
    assert_equal @poll.author, n.user
    assert_equal 'poll_expired', n.kind
  end

  test "poll_expired does not email author when volume quiet" do
    @poll.author = @user_thread_quiet
    @poll.save!
    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      Events::PollExpired.publish!(@poll)
    end
  end

  test "poll_expired emails author when volume loud" do
    @poll.author = @user_thread_loud
    @poll.save!
    assert_difference -> { ActionMailer::Base.deliveries.count } do
      Events::PollExpired.publish!(@poll)
    end
  end

  test "stance_created notifies author if volume loud" do
    @poll.stances.create!(participant: @poll.author, email_volume: 'loud')
    stance = Stance.create!(poll: @poll, participant: @user_thread_normal, choice: 'Agree', cast_at: Time.current)
    assert_difference -> { ActionMailer::Base.deliveries.count }, 3 do
      Events::StanceCreated.publish!(stance)
    end
    email_users = Events::StanceCreated.last.send(:subscribed_recipients)
    assert_equal 3, email_users.length
    assert_includes email_users, @poll.author
    assert_includes email_users, @user_thread_loud
    assert_includes email_users, @user_membership_loud
  end

  test "stance_created does not notify author if volume normal" do
    @poll.stances.create!(participant: @poll.author, email_volume: 'normal')
    stance = Stance.create!(poll: @poll, participant: @user_thread_normal, choice: 'Agree', cast_at: Time.current)
    assert_difference -> { ActionMailer::Base.deliveries.count }, 2 do
      Events::StanceCreated.publish!(stance)
    end
    email_users = Events::StanceCreated.last.send(:subscribed_recipients)
    assert_equal 2, email_users.length
    assert_includes email_users, @user_thread_loud
    assert_includes email_users, @user_membership_loud
  end

  test "stance_created does not notify deactivated users" do
    [@user_thread_loud, @user_membership_loud].each { |u| u.update!(deactivated_at: Time.current) }
    @poll.stances.create!(participant: @poll.author, email_volume: 'normal')
    stance = Stance.create!(poll: @poll, participant: @user_thread_normal, choice: 'Agree', cast_at: Time.current)
    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      Events::StanceCreated.publish!(stance)
    end
    assert Events::StanceCreated.last.send(:subscribed_recipients).empty?
  end

  test "poll_announced does not email people with stance volume quiet" do
    stance = Stance.create!(participant: @user_thread_normal, poll: @poll, email_volume: :quiet)
    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      Events::PollAnnounced.publish!(poll: @poll, actor: @poll.author, stances: [stance])
    end
  end

  test "poll_announced sends invitations" do
    stance = Stance.create!(participant: @user_thread_normal, poll: @poll)
    assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
      Events::PollAnnounced.publish!(poll: @poll, actor: @poll.author, stances: [stance])
    end
  end

  test "outcome_created notifies the author and mentioned" do
    meeting_poll = Poll.new(poll_type: 'meeting', title: "Meeting #{SecureRandom.hex(4)}",
                            closing_at: 5.days.from_now, author: @author,
                            discussion: @discussion, group: @group,
                            poll_option_names: ["2026-02-15"], specified_voters_only: true)
    PollService.create(poll: meeting_poll, actor: @author)
    meeting_poll.create_missing_created_event!

    outcome = Outcome.create!(poll: meeting_poll, author: @author, statement: @user_mentioned_text)
    assert_difference -> { ActionMailer::Base.deliveries.count }, 4 do
      Events::OutcomeCreated.publish!(outcome: outcome, recipient_user_ids: [outcome.author.id])
    end
    assert_includes Events::UserMentioned.last.custom_fields['user_ids'], @mentioned_user.id
    assert_equal 2, Events::OutcomeCreated.last.subscribed_recipients.length
    recipients = ActionMailer::Base.deliveries.map(&:to).flatten
    assert_includes recipients, @mentioned_user.email
    assert_includes recipients, outcome.author.email
    assert_includes recipients, @user_membership_loud.email
    assert_includes recipients, @user_thread_loud.email
  end
end
