require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)
    @group.update_columns(members_can_announce: true)

    @mentioned_user = users(:user)
    @user_mentioned_text = "Hello @#{@mentioned_user.username}"

    @discussion = DiscussionService.build(params: {
      group_id: @group.id,
      title: "Event Test Discussion",
      description: @user_mentioned_text, description_format: 'md',
      private: true
    }, actor: @admin)

    @discussion.save!

    @user_thread_loud = create_unique_user("tloud")
    @user_thread_normal = create_unique_user("tnorm")
    @user_thread_quiet = create_unique_user("tquiet")
    @user_thread_mute = create_unique_user("tmute")
    @user_membership_loud = create_unique_user("mloud")
    @user_membership_normal = create_unique_user("mnorm")
    @user_membership_quiet = create_unique_user("mquiet")
    @user_membership_mute = create_unique_user("mmute")
    @user_left_group = create_unique_user("left")

    # User who left group
    m = @group.add_member!(@user_left_group)
    TopicReader.for(user: @user_left_group, topic: @discussion.topic).set_volume!(:loud)
    m.update_columns(revoked_at: Time.now, revoker_id: @user_left_group.id)

    # Thread volume users (membership muted, thread overrides)
    [@user_thread_loud, @user_thread_normal, @user_thread_quiet, @user_thread_mute].each do |u|
      @group.add_member!(u).set_volume!(:mute)
    end
    @group.membership_for(@mentioned_user).set_volume!(:mute)

    TopicReader.for(user: @user_thread_loud, topic: @discussion.topic).set_volume!(:loud)
    TopicReader.for(user: @user_thread_normal, topic: @discussion.topic).set_volume!(:normal)
    TopicReader.for(user: @user_thread_quiet, topic: @discussion.topic).set_volume!(:quiet)
    TopicReader.for(user: @user_thread_mute, topic: @discussion.topic).set_volume!(:mute)

    # Membership volume users
    @group.add_member!(@user_membership_loud).set_volume!(:loud)
    @group.add_member!(@user_membership_normal).set_volume!(:normal)
    @group.add_member!(@user_membership_quiet).set_volume!(:quiet)
    @group.add_member!(@user_membership_mute).set_volume!(:mute)

    # Webhook
    @webhook_url = "https://webhook-#{SecureRandom.hex(4)}.example.com/hook"
    WebMock.stub_request(:post, @webhook_url).to_return(status: 200)
    @webhook = Chatbot.create!(
      group: @group, author: @admin, name: "Test Webhook",
      server: @webhook_url, webhook_kind: 'markdown', kind: 'webhook',
      event_kinds: %w[new_discussion discussion_edited poll_created poll_edited poll_closing_soon poll_expired poll_announced poll_reopened outcome_created]
    )

    # Create poll without PollService.create to avoid publishing events/emails in setup
    @poll = PollService.build(params: {
      poll_type: 'proposal',
      title: "Event Poll",
      poll_option_names: %w[agree disagree abstain],
      closing_at: 1.day.from_now,
      topic: @discussion.topic,
      details: @user_mentioned_text,
      specified_voters_only: true
    }, actor: @admin)
    @poll.save!
    @poll.create_missing_created_event!

    ActionMailer::Base.deliveries.clear
  end

  test "new_comment sends emails to loud subscribers" do
    comment = Comment.new(body: "hello", parent: @discussion)
    event = CommentService.create(comment: comment, actor: @admin)
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
    comment = Comment.new(body: "hello @#{@mentioned_user.username}", parent: @discussion)
    CommentService.create(comment: comment, actor: @admin)
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
      event = Events::NewDiscussion.publish!(discussion: @discussion)
      assert_equal 1, @discussion.mentioned_users.length
      assert_equal 2, event.subscribed_recipients.length
    end
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
    assert_not Notification.joins(:event).where('notifications.user_id': @user_thread_loud.id).exists?
    assert_difference -> { Events::UserMentioned.where(kind: :user_mentioned).count }, 1 do
      Events::PollEdited.publish!(poll: @poll, actor: @poll.author)
    end
    assert_includes Events::UserMentioned.last.custom_fields['user_ids'], @user_thread_loud.id
    assert Notification.joins(:event).where('notifications.user_id': @user_thread_loud.id).exists?
  end

  test "poll_closing_soon notify_on_closing_soon voters" do
    @poll.update!(notify_on_closing_soon: 'voters')
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_loud, cast_at: Time.current)
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_normal, cast_at: Time.current)
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_quiet, cast_at: Time.current)
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_mute, cast_at: Time.current)

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
    @poll.stances.create!(participant: @poll.author)
    TopicReader.find_or_create_by!(topic: @poll.topic, user: @poll.author).set_volume!('loud')
    stance = Stance.create!(poll: @poll, participant: @user_thread_normal, choice: 'Agree', reason: "I agree", cast_at: Time.current)
    event = nil
    assert_difference -> { ActionMailer::Base.deliveries.count }, 3 do
      event = Events::StanceCreated.publish!(stance)
    end
    email_users = event.send(:subscribed_recipients)
    assert_equal 3, email_users.length
    assert_includes email_users, @poll.author
    assert_includes email_users, @user_thread_loud
    assert_includes email_users, @user_membership_loud
  end

  test "stance_created does not notify author if volume normal" do
    @poll.stances.create!(participant: @poll.author)
    stance = Stance.create!(poll: @poll, participant: @user_thread_normal, choice: 'Agree', reason: "I agree", cast_at: Time.current)
    event = nil
    assert_difference -> { ActionMailer::Base.deliveries.count }, 2 do
      event = Events::StanceCreated.publish!(stance)
    end
    email_users = event.subscribed_recipients
    assert_equal 2, email_users.length
    assert_includes email_users, @user_thread_loud
    assert_includes email_users, @user_membership_loud
  end

  test "stance_created does not notify deactivated users" do
    [@user_thread_loud, @user_membership_loud].each { |u| u.update!(deactivated_at: Time.current) }
    @poll.stances.create!(participant: @poll.author)
    stance = Stance.create!(poll: @poll, participant: @user_thread_normal, choice: 'Agree', cast_at: Time.current)
    event = nil
    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      event = Events::StanceCreated.publish!(stance)
    end
    assert event.send(:subscribed_recipients).empty?
  end

  test "poll_announced does not email people with topic reader volume quiet" do
    stance = Stance.create!(participant: @user_thread_normal, poll: @poll)
    TopicReader.find_or_create_by!(topic: @poll.topic, user: @user_thread_normal).set_volume!('quiet')
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
                            closing_at: 5.days.from_now, author: @admin,
                            topic: @discussion.topic,
                            poll_option_names: ["2026-02-15"], specified_voters_only: true)
    meeting_poll.save!
    meeting_poll.create_missing_created_event!

    outcome = Outcome.create!(poll: meeting_poll, author: @admin, statement: @user_mentioned_text)
    event = nil
    assert_difference -> { ActionMailer::Base.deliveries.count }, 4 do
      event = Events::OutcomeCreated.publish!(outcome: outcome, recipient_user_ids: [outcome.author.id])
    end
    assert_includes Events::UserMentioned.last.custom_fields['user_ids'], @mentioned_user.id
    assert_equal 2, event.subscribed_recipients.length
    recipients = ActionMailer::Base.deliveries.map(&:to).flatten
    assert_includes recipients, @mentioned_user.email
    assert_includes recipients, outcome.author.email
    assert_includes recipients, @user_membership_loud.email
    assert_includes recipients, @user_thread_loud.email
  end

  private

  def create_unique_user(prefix)
    User.create!(
      name: prefix.titleize,
      email: "#{prefix}#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      username: "#{prefix}#{SecureRandom.hex(4)}"
    )
  end
end
