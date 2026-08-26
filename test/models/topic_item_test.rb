require 'test_helper'

class EventTest < ActiveSupport::TestCase
  inline_jobs
  setup do
    @admin = users(:admin)
    @group = groups(:group)
    @group.update_columns(members_can_announce: true)

    @mentioned_user = users(:user)
    @user_mentioned_text = "Hello @#{@mentioned_user.username}"

    @discussion = DiscussionService.build(params: {
      group_id: @group.id,
      title: "TopicItem Test Discussion",
      description: @user_mentioned_text, description_format: 'md',
      private: true
    }, actor: @admin)

    @discussion.save!
    @discussion.create_missing_created_topic_item!

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
    SafeHttpService.stub(:safe_to_fetch?, true) do
      @webhook = Chatbot.create!(
        group: @group, author: @admin, name: "Test Webhook",
        server: @webhook_url, webhook_kind: 'markdown', kind: 'webhook',
        event_kinds: %w[new_discussion discussion_edited poll_created poll_edited poll_closing_soon poll_expired poll_announced poll_reopened outcome_created]
      )
    end

    # Create poll without PollService.create to avoid publishing topic_items/emails in setup
    @poll = PollService.build(params: {
      poll_type: 'proposal',
      title: "TopicItem Poll",
      poll_option_names: %w[agree disagree abstain],
      closing_at: 1.day.from_now,
      topic: @discussion.topic,
      details: @user_mentioned_text,
      specified_voters_only: true
    }, actor: @admin)
    @poll.save!
    @poll.create_missing_created_topic_item!

    ActionMailer::Base.deliveries.clear
  end

  test "new_comment sends emails to loud subscribers" do
    comment = Comment.new(body: "hello", parent: @discussion)
    CommentService.create(comment: comment, actor: @admin)
    recipient_emails = ActionMailer::Base.deliveries.map(&:to).flatten
    assert_includes recipient_emails, @user_thread_loud.email
    assert_includes recipient_emails, @user_membership_loud.email
    assert_not_includes recipient_emails, @user_left_group.email
    assert_not_includes recipient_emails, @user_membership_normal.email
    assert_not_includes recipient_emails, @user_thread_normal.email
    assert_not_includes recipient_emails, @user_membership_quiet.email
    assert_not_includes recipient_emails, @user_thread_quiet.email
    assert_not_includes recipient_emails, @user_membership_mute.email
    assert_not_includes recipient_emails, @user_thread_mute.email
    assert_not Notification.about(comment).exists?(kind: "new_comment")
  end

  test "topic item publication side effects are enqueued after commit" do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
    comment = Comment.new(body: "queued publication", parent: @discussion)

    assert_enqueued_with(job: PublishLiveUpdateTopicItemWorker) do
      assert_enqueued_with(job: PublishSubscriberEmailsTopicItemWorker) do
        CommentService.create(comment: comment, actor: @admin)
      end
    end
  end

  test "live updates are skipped when itemable has been deleted" do
    topic_item = @discussion.created_topic_item
    @discussion.delete

    assert_nothing_raised do
      MessageChannelService.stub(:publish_models, ->(*) { raise "should not publish" }) do
        PublishLiveUpdateTopicItemWorker.perform_now(topic_item.id)
      end
    end
  end

  test "database rejects a missing parent topic_item" do
    topic_item = topic_items(:public_discussion_comment_topic_item)

    assert_raises(ActiveRecord::InvalidForeignKey) do
      topic_item.update_columns(parent_id: TopicItem.maximum(:id) + 100)
    end
  end

  test "stance notification links to its poll in the discussion" do
    stance = Stance.new(poll: @poll, participant: @mentioned_user)
    notification = Notification.new(kind: "stance_created", subject: stance, actor: @admin)

    assert_includes notification.notification_url, "/d/#{@discussion.key}"
    assert notification.notification_url.end_with?("/#{@poll.created_topic_item.sequence_id}")
  end

  test "topic item notification links to its exact sequence" do
    topic_item = TopicItem.create!(kind: "poll_edited", itemable: @poll, user: @admin)
    notification = Notification.new(kind: "poll_edited", subject: topic_item, actor: @admin)

    assert_includes notification.notification_url, "/d/#{@discussion.key}"
    assert notification.notification_url.end_with?("/#{topic_item.sequence_id}")
    refute_equal @poll.created_topic_item.sequence_id, topic_item.sequence_id
  end

  test "user_mentioned notifies mentioned user" do
    @mentioned_user.update!(username: 'mentioned-user')
    comment = Comment.new(body: "hello @#{@mentioned_user.username}", parent: @discussion)
    CommentService.create(comment: comment, actor: @admin)
    notification = Notification.find_by!(kind: "user_mentioned", subject: comment.created_topic_item)
    assert_equal comment.created_topic_item, notification.subject
    assert_equal [ @mentioned_user.id ], notification.recipient_user_ids
    assert_equal [ @mentioned_user.id ], notification.notification_deliveries.where(channel: "email").pluck(:recipient_id)
    assert_equal [ @mentioned_user.id ], notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id)
  end

  test "new mentions from a comment edit create a separate notification for the same topic item" do
    comment = Comment.new(body: "hello @#{@mentioned_user.username}", parent: @discussion)
    CommentService.create(comment: comment, actor: @admin)

    CommentService.update(
      comment: comment,
      params: { body: "#{comment.body} and @#{@user_thread_normal.username}" },
      actor: @admin
    )

    notifications = Notification.where(kind: "user_mentioned", subject: comment.created_topic_item).order(:id)
    assert_equal 2, notifications.count
    assert_equal [ comment.created_topic_item.id ], notifications.pluck(:subject_id).uniq
    assert_equal [ @mentioned_user.id ], notifications.first.recipient_user_ids
    assert_equal [ @user_thread_normal.id ], notifications.second.recipient_user_ids
  end

  test "new_discussion notifies mentioned users" do
    topic_item = TopicItems::NewDiscussion.find(@discussion.created_topic_item.id)
    MentionNotificationService.create!(
      subject: @discussion,
      actor: @admin
    )
    assert_difference -> { ActionMailer::Base.deliveries.count }, 2 do
      Resolv.stub(:getaddresses, [ "93.184.216.34" ]) do
        NotificationService.create!(
          kind: "new_discussion",
          subject: @discussion,
          actor: @admin,
          audience_values: {
            newly_mentioned_user_ids: @discussion.newly_mentioned_users.pluck(:id),
            mentioned_user_ids: @discussion.mentioned_users.pluck(:id),
            mentioned_group_user_ids: @discussion.mentioned_group_users.pluck(:id)
          }
        )
        PublishSubscriberEmailsTopicItemWorker.perform_now(topic_item.id)
      end
      assert_equal 1, @discussion.mentioned_users.length
    end
    notification = Notification.find_by!(kind: "user_mentioned", subject: @discussion.created_topic_item)
    assert_includes notification.recipient_user_ids, @mentioned_user.id
  end

  test "poll_created notifies mentioned users and loud subscribers" do
    topic_item = TopicItems::PollCreated.find(@poll.created_topic_item.id)
    MentionNotificationService.create!(
      subject: @poll,
      actor: @admin
    )
    PublishSubscriberEmailsTopicItemWorker.perform_now(topic_item.id)
    assert_equal 1, @poll.mentioned_users.length
    notification = Notification.find_by!(kind: "user_mentioned", subject: @poll.created_topic_item)
    assert_includes notification.recipient_user_ids, @mentioned_user.id
    recipient_emails = ActionMailer::Base.deliveries.flat_map(&:to)
    assert_includes recipient_emails, @user_thread_loud.email
    assert_includes recipient_emails, @user_membership_loud.email
    assert_not Notification.about(@poll).exists?(kind: "poll_created")
  end

  test "poll_created notifies webhook" do
    Resolv.stub(:getaddresses, ->(_host) { ['93.184.216.34'] }) do
      ChatbotService.publish_topic_item!(@poll.created_topic_item.id)
    end
    assert_requested :post, @webhook_url, at_least_times: 1
    assert_not Notification.about(@poll).exists?(kind: "poll_created")
  end

  test "poll_edited notifies newly mentioned users" do
    @poll.update!(details: "#{@poll.details} and @#{@user_thread_loud.username}")
    mention_scope = Notification.where(kind: "user_mentioned", subject: @poll.created_topic_item)
    assert_not mention_scope.where("? = ANY(recipient_user_ids)", @user_thread_loud.id).exists?
    assert_difference -> { mention_scope.count }, 1 do
      MentionNotificationService.create!(
        subject: @poll,
        actor: @poll.author
      )
    end
    notification = Notification.where(kind: "user_mentioned", subject: @poll.created_topic_item)
                               .find_by!("? = ANY(recipient_user_ids)", @user_thread_loud.id)
    assert_includes notification.recipient_user_ids, @user_thread_loud.id
    assert_includes notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id), @user_thread_loud.id
  end

  test "poll_closing_soon notify_on_closing_soon voters" do
    @poll.update!(notify_on_closing_soon: 'voters')
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_loud, cast_at: Time.current)
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_normal, cast_at: Time.current)
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_quiet, cast_at: Time.current)
    Stance.create!(poll: @poll, choice: 'Agree', participant: @user_thread_mute, cast_at: Time.current)

    assert_difference -> { ActionMailer::Base.deliveries.count }, 2 do
      NotificationService.create!(kind: "poll_closing_soon", subject: @poll, actor: @poll.author)
    end

    notification = Notification.find_by!(kind: "poll_closing_soon", subject: @poll)
    notified_ids = notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id)
    assert_equal [ @user_thread_loud.id, @user_thread_normal.id, @user_thread_quiet.id ].sort, notified_ids.sort
    emailed_ids = notification.notification_deliveries.where(channel: "email").pluck(:recipient_id)
    assert_equal [ @user_thread_loud.id, @user_thread_normal.id ].sort, emailed_ids.sort
  end

  test "poll_closing_soon notify_on_closing_soon undecided_voters" do
    @poll.update!(notify_on_closing_soon: 'undecided_voters')
    Stance.create!(poll: @poll, cast_at: Time.current, choice: 'Agree', participant: @user_thread_loud)
    Stance.create!(poll: @poll, participant: @user_thread_normal)

    assert_difference -> { ActionMailer::Base.deliveries.count } do
      NotificationService.create!(kind: "poll_closing_soon", subject: @poll, actor: @poll.author)
    end

    notification = Notification.find_by!(kind: "poll_closing_soon", subject: @poll)
    assert_equal [ @user_thread_normal.id ], notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id)
    assert_equal [ @user_thread_normal.id ], notification.notification_deliveries.where(channel: "email").pluck(:recipient_id)
  end

  test "poll_closing_soon notify_on_closing_soon author" do
    @poll.update!(notify_on_closing_soon: 'author')
    assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
      NotificationService.create!(kind: "poll_closing_soon", subject: @poll, actor: @poll.author)
    end
    notification = Notification.find_by!(kind: "poll_closing_soon", subject: @poll)
    assert_equal [ @poll.author_id ], notification.notification_deliveries.where(channel: "email").pluck(:recipient_id)
  end

  test "poll_closing_soon notify_on_closing_soon nobody" do
    @poll.update!(notify_on_closing_soon: 'nobody')
    Stance.create!(poll: @poll, cast_at: Time.current, choice: 'Agree', participant: @user_thread_loud)
    Stance.create!(poll: @poll, participant: @user_thread_normal)

    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      NotificationService.create!(kind: "poll_closing_soon", subject: @poll, actor: @poll.author)
    end

    notification = Notification.find_by!(kind: "poll_closing_soon", subject: @poll)
    assert_empty notification.notification_deliveries.where(recipient_type: "User")
  end

  test "poll_expired creates an in-app notification for the author" do
    @poll.update_column(:closed_at, Time.current)
    assert_difference -> { ActionMailer::Base.deliveries.count } do
      NotificationService.create!(kind: "poll_expired", subject: @poll, actor: @poll.author)
    end
    notification = Notification.find_by!(kind: "poll_expired", subject: @poll)
    assert_equal [ @poll.author_id ], notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id)
  end

  test "poll_expired does not email author when volume quiet" do
    @poll.update_column(:closed_at, Time.current)
    @poll.author = @user_thread_quiet
    @poll.save!
    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      NotificationService.create!(kind: "poll_expired", subject: @poll, actor: @poll.author)
    end
  end

  test "poll_expired emails author when volume loud" do
    @poll.update_column(:closed_at, Time.current)
    @poll.author = @user_thread_loud
    @poll.save!
    assert_difference -> { ActionMailer::Base.deliveries.count } do
      NotificationService.create!(kind: "poll_expired", subject: @poll, actor: @poll.author)
    end
  end

  test "stance_created notifies author if volume loud" do
    @poll.stances.create!(participant: @poll.author)
    TopicReader.find_or_create_by!(topic: @poll.topic, user: @poll.author).set_volume!('loud')
    stance = @poll.stances.create!(participant: @user_thread_normal, inviter: @admin, latest: true, reason: "I agree")
    stance.choice = @poll.poll_option_names.first
    StanceService.create(stance: stance, actor: @user_thread_normal)
    recipient_emails = ActionMailer::Base.deliveries.flat_map(&:to)
    assert_includes recipient_emails, @poll.author.email
    assert_includes recipient_emails, @user_thread_loud.email
    assert_includes recipient_emails, @user_membership_loud.email
    assert_not Notification.about(stance).exists?(kind: "stance_created")
  end

  test "stance_created does not notify author if volume normal" do
    @poll.stances.create!(participant: @poll.author)
    stance = @poll.stances.create!(participant: @user_thread_normal, inviter: @admin, latest: true, reason: "I agree")
    stance.choice = @poll.poll_option_names.first
    StanceService.create(stance: stance, actor: @user_thread_normal)
    recipient_emails = ActionMailer::Base.deliveries.flat_map(&:to)
    assert_not_includes recipient_emails, @poll.author.email
    assert_includes recipient_emails, @user_thread_loud.email
    assert_includes recipient_emails, @user_membership_loud.email
    assert_not Notification.about(stance).exists?(kind: "stance_created")
  end

  test "stance_created does not notify deactivated users" do
    [@user_thread_loud, @user_membership_loud].each { |u| u.update!(deactivated_at: Time.current) }
    @poll.stances.create!(participant: @poll.author)
    stance = @poll.stances.create!(participant: @user_thread_normal, inviter: @admin, latest: true)
    stance.choice = @poll.poll_option_names.first
    StanceService.create(stance: stance, actor: @user_thread_normal)
    assert_not Notification.about(stance).exists?(kind: "stance_created")
    assert_empty ActionMailer::Base.deliveries
  end

  test "stance_created uses shared delivery when results are hidden until vote" do
    @poll.update!(hide_results: 'until_vote')
    stance = @poll.stances.create!(participant: @user_thread_normal, inviter: @admin, latest: true, reason: "Response")
    stance.choice = @poll.poll_option_names.first
    topic_item = StanceService.create(stance: stance, actor: @user_thread_normal)

    assert_equal @poll.topic_id, topic_item.topic_id
    assert_not Notification.about(stance).exists?(kind: "stance_created")

    publish_count = 0
    MessageChannelService.stub(:publish_models, ->(*) { publish_count += 1 }) do
      PublishLiveUpdateTopicItemWorker.perform_now(topic_item.id)
    end
    assert_operator publish_count, :>, 0
  end

  test "stance_created suppresses shared delivery while results are hidden until close" do
    @poll.update!(hide_results: 'until_closed')
    stance = @poll.stances.create!(participant: @user_thread_normal, inviter: @admin, latest: true, reason: "Hidden response")
    stance.choice = @poll.poll_option_names.first
    publish_count = 0
    result = nil
    MessageChannelService.stub(:publish_topic_model, ->(*) { publish_count += 1 }) do
      result = StanceService.create(stance: stance, actor: @user_thread_normal)
    end

    assert_equal stance, result
    assert_not Notification.about(stance).exists?(kind: "stance_created")
    assert_equal 0, publish_count
  end

  test "poll_announced does not email people with topic reader volume quiet" do
    stance = Stance.create!(participant: @user_thread_normal, poll: @poll)
    TopicReader.find_or_create_by!(topic: @poll.topic, user: @user_thread_normal).set_volume!('quiet')
    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      NotificationService.create!(
        kind: "poll_announced",
        subject: @poll,
        actor: @poll.author,
        recipient_user_ids: [ stance.participant_id ]
      )
    end
  end

  test "poll_announced sends invitations" do
    stance = Stance.create!(participant: @user_thread_normal, poll: @poll)
    assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
      NotificationService.create!(
        kind: "poll_announced",
        subject: @poll,
        actor: @poll.author,
        recipient_user_ids: [ stance.participant_id ]
      )
    end
  end

  test "outcome_created notifies the author and mentioned" do
    meeting_poll = Poll.new(poll_type: 'meeting', title: "Meeting #{SecureRandom.hex(4)}",
                            closing_at: 5.days.from_now, author: @admin,
                            topic: @discussion.topic,
                            poll_option_names: ["2026-02-15"], specified_voters_only: true)
    meeting_poll.save!
    meeting_poll.create_missing_created_topic_item!

    outcome = Outcome.new(poll: meeting_poll, author: @admin, statement: @user_mentioned_text)
    OutcomeService.create(
      outcome: outcome,
      actor: @admin,
      params: { recipient_user_ids: [ @admin.id ] }
    )
    notification = Notification.find_by!(kind: "user_mentioned", subject: outcome.created_topic_item)
    assert_includes notification.recipient_user_ids, @mentioned_user.id
    parent_notification = Notification.find_by!(kind: "outcome_created", subject: outcome.created_topic_item)
    delivery_recipient_ids = parent_notification.notification_deliveries.where(channel: "email").pluck(:recipient_id)
    assert_equal [ @admin.id ], delivery_recipient_ids
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
