require 'test_helper'

class EmailActionsControllerTest < ActionController::TestCase
  inline_jobs "marks the discussion as read at topic_item created_at",
              "marks a comment as read",
              "marks digest notifications as viewed"
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "eauser#{hex}", email: "eauser#{hex}@example.com", username: "eauser#{hex}", email_verified: true)
    @author = User.create!(name: "eaauthor#{hex}", email: "eaauthor#{hex}@example.com", username: "eaauthor#{hex}", email_verified: true)
    @group = Group.new(name: "eagroup#{hex}", group_privacy: 'secret')
    @group.creator = @author
    @group.save!
    @group.add_member!(@user)
    @group.add_member!(@author)
    @membership = Membership.find_by(group: @group, user: @user)

    @discussion = DiscussionService.create(params: { title: "Discussion #{hex}", group_id: @group.id }, actor: @author)
    @topic = @discussion.topic
    @topic_item = @discussion.created_topic_item
    @topic_reader = TopicReader.for(user: @user, topic: @topic)
    ActionMailer::Base.deliveries.clear
  end

  test "a token holder can view catch-up settings without signing in" do
    @user.update!(email_catch_up_day: 1)

    get :catch_up, params: {unsubscribe_token: @user.unsubscribe_token}

    assert_response :success
    assert_select "select[name=email_catch_up_day] option[value='1'][selected]"
    assert_select "input#email_catch_up_save[type=submit]"
    assert_includes response.body, "save.disabled = schedule.value === savedValue"
    assert_select "input[name=unsubscribe_token][value='#{@user.unsubscribe_token}']"
    assert_equal 'no-referrer', response.headers['Referrer-Policy']
    assert_equal 'no-store', response.headers['Cache-Control']
  end

  test "a token holder can change or stop catch-up emails without signing in" do
    put :set_catch_up, params: {unsubscribe_token: @user.unsubscribe_token, email_catch_up_day: '8'}

    assert_redirected_to email_actions_catch_up_path(unsubscribe_token: @user.unsubscribe_token)
    assert_equal 8, @user.reload.email_catch_up_day

    get :catch_up, params: {unsubscribe_token: @user.unsubscribe_token}
    assert_select ".flash-notice", text: I18n.t('email_actions.catch_up_saved')

    put :set_catch_up, params: {unsubscribe_token: @user.unsubscribe_token, email_catch_up_day: 'never'}

    assert_response :redirect
    assert_nil @user.reload.email_catch_up_day
  end

  test "catch-up settings reject an invalid day" do
    @user.update!(email_catch_up_day: 7)

    put :set_catch_up, params: {unsubscribe_token: @user.unsubscribe_token, email_catch_up_day: '9'}

    assert_response :unprocessable_entity
    assert_select "main.sistema h1", text: I18n.t('errors.422.title')
    assert_equal 7, @user.reload.email_catch_up_day
  end

  test "a missing thread or group renders a Rails 404 page" do
    get :unsubscribe, params: {unsubscribe_token: @user.unsubscribe_token}

    assert_response :not_found
    assert_select "main.sistema h1", text: I18n.t('errors.404.title')
    assert_select "#app", count: 0
  end

  test "a missing thread or group still returns a JSON error to API clients" do
    get :unsubscribe, params: {unsubscribe_token: @user.unsubscribe_token}, format: :json

    assert_response :not_found
    assert_equal I18n.t('errors.404.title'), JSON.parse(response.body)['error']
  end

  test "an invalid email token cannot use a signed-in account as a fallback" do
    sign_in @author

    put :set_catch_up, params: {unsubscribe_token: 'invalid', email_catch_up_day: 'never'}

    assert_response :forbidden
    assert_equal 7, @user.reload.email_catch_up_day
  end

  test "the thread notification form links to catch-up email settings" do
    @user.update!(email_catch_up_day: 7)
    get :unsubscribe, params: {topic_id: @topic.id, unsubscribe_token: @user.unsubscribe_token}

    assert_select "a[href='#{email_actions_catch_up_path(unsubscribe_token: @user.unsubscribe_token)}']", text: I18n.t('email_actions.catch_up_link')
    assert_select ".email-action-secondary-link", text: /#{Regexp.escape(I18n.t('email_actions.catch_up_all_groups'))}: #{Regexp.escape(I18n.t('email_actions.catch_up_days.every_day'))}/
  end

  # unsubscribe page rendering
  test "unsubscribe renders with topic reader" do
    @topic_reader.set_volume!(email: :loud, push: :quiet)

    get :unsubscribe, params: { topic_id: @topic.id, unsubscribe_token: @user.unsubscribe_token }
    assert_response :success
    assert_select "select[name=delivery_channel]", count: 0
    assert_select "input[type=radio][name=volume_email]", count: 3
    assert_select "input[type=radio][name=volume_email][value=loud][checked]"
    assert_select "input[type=checkbox][name=apply_to_group]:not([checked])"
    assert_select "label[for=apply_to_group]", text: "Apply these settings to all threads in #{@group.full_name}"
    assert_select ".volume-choice-title", text: I18n.t("change_volume_form.all_activity_option")
    assert_select ".volume-choice-description", text: I18n.t("change_volume_form.email_all_activity_description", context: I18n.t("change_volume_form.context.thread"))
  end

  test "unsubscribe renders delivery method and push levels for a user with a registered device" do
    session = @user.sessions.create!(user_agent: "test browser", ip_address: "127.0.0.2")
    create_push_subscription(
      user: @user,
      session: session,
      endpoint: "https://fcm.googleapis.com/fcm/send/email-actions-token",
      p256dh_key: "p256dh-key",
      auth_key: "auth-key"
    )

    get :unsubscribe, params: { topic_id: @topic.id, unsubscribe_token: @user.unsubscribe_token }

    assert_response :success
    assert_select "select[name=delivery_channel]", count: 1
    assert_select "select[name=delivery_channel] option", count: 3
    assert_select "input[type=radio][name=volume_push]", count: 3
    assert_includes response.body, "option[value=email]:checked"
    refute_includes response.body, "option[value=&quot;email&quot;]:checked"
  end

  test "unsubscribe renders with stance and topic reader" do
    poll = PollService.create(params: {
      title: "Unsub Poll #{SecureRandom.hex(4)}",
      poll_type: 'proposal',
      topic_id: @topic.id,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    }, actor: @author)

    get :unsubscribe, params: {
      topic_id: @topic.id,
      unsubscribe_token: @user.unsubscribe_token
    }
    assert_response :success
  end

  test "unsubscribe resolves a legacy poll link through its topic" do
    poll = PollService.create(params: {
      title: "Unsub Poll #{SecureRandom.hex(4)}",
      poll_type: 'proposal',
      topic_id: @topic.id,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    }, actor: @author)

    get :unsubscribe, params: {
      poll_id: poll.id,
      unsubscribe_token: @user.unsubscribe_token
    }

    assert_response :success
    assert_select "input[name=topic_id][value='#{@topic.id}']"
  end

  test "unsubscribe resolves a legacy comment link through its topic" do
    comment = CommentService.create(
      comment: Comment.new(parent: @discussion, body: "Legacy unsubscribe link"),
      actor: @author
    )

    get :unsubscribe, params: {
      comment_id: comment.id,
      unsubscribe_token: @user.unsubscribe_token
    }

    assert_response :success
    assert_select "input[name=topic_id][value='#{@topic.id}']"
  end

  test "unsubscribe rejects a legacy poll link when the token user cannot access its topic" do
    group = Group.create!(name: "Private group #{SecureRandom.hex(4)}", group_privacy: "secret", creator: @author)
    group.add_admin!(@author)
    poll = PollService.create(params: {
      title: "Private poll #{SecureRandom.hex(4)}",
      poll_type: 'proposal',
      group_id: group.id,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain],
      notify_on_open: false
    }, actor: @author)

    get :unsubscribe, params: {
      poll_id: poll.id,
      unsubscribe_token: @user.unsubscribe_token
    }

    assert_redirected_to dashboard_path
  end

  # set_volume tests
  test "unsubscribes membership" do
    @membership.set_volume!(email: :loud, push: :quiet)
    @topic_reader.set_volume!(email: :loud, push: :quiet)

    put :set_group_volume, params: {
      group_id: @group.id,
      unsubscribe_token: @user.unsubscribe_token,
      delivery_channel: :push,
      volume_email: :normal,
      volume_push: :normal
    }
    assert_response 302
    assert_equal 'no-referrer', response.headers['Referrer-Policy']
    assert_equal 'no-store', response.headers['Cache-Control']

    @membership.reload
    @topic_reader.reload

    assert_equal 'quiet', @membership.volume_email
    assert_equal 'quiet', @topic_reader.volume_email
    assert_equal 'normal', @membership.volume_push
    assert_equal 'normal', @topic_reader.volume_push
  end

  test "quiets membership" do
    @membership.set_volume!(email: :loud, push: :quiet)
    @topic_reader.set_volume!(email: :loud, push: :quiet)

    put :set_group_volume, params: { group_id: @group.id, unsubscribe_token: @user.unsubscribe_token, value: :quiet }
    assert_response 302

    @membership.reload
    @topic_reader.reload

    assert_equal 'quiet', @membership.volume_email
    assert_equal 'quiet', @topic_reader.volume_email
  end

  test "unsubscribes discussion" do
    @membership.set_volume!(email: :normal, push: :quiet)
    @topic_reader.set_volume!(email: :loud, push: :quiet)

    put :set_discussion_volume, params: { topic_id: @topic.id, unsubscribe_token: @user.unsubscribe_token, value: :normal }
    assert_response 302

    @membership.reload
    @topic_reader.reload

    assert_equal 'normal', @membership.volume_email
    assert_equal 'normal', @topic_reader.volume_email
  end

  test "applies discussion settings to every topic in its group" do
    another_discussion = DiscussionService.create(
      params: {title: "Another discussion #{SecureRandom.hex(4)}", group_id: @group.id},
      actor: @author
    )
    another_reader = TopicReader.for(user: @user, topic: another_discussion.topic)
    @membership.set_volume!(email: :normal, push: :quiet)
    @topic_reader.set_volume!(email: :loud, push: :normal)
    another_reader.set_volume!(email: :loud, push: :normal)

    put :set_discussion_volume, params: {
      topic_id: @topic.id,
      unsubscribe_token: @user.unsubscribe_token,
      delivery_channel: :email,
      volume_email: :quiet,
      volume_push: :normal,
      apply_to_group: "1"
    }

    assert_response :redirect
    assert_equal "quiet", @membership.reload.volume_email
    assert_equal "quiet", @topic_reader.reload.volume_email
    assert_equal "quiet", another_reader.reload.volume_email
    assert_equal "quiet", @membership.volume_push
    assert_equal "quiet", @topic_reader.volume_push
    assert_equal "quiet", another_reader.volume_push
  end

  # mark_discussion_as_read tests
  test "marks the discussion as read at topic_item created_at" do
    get :mark_discussion_as_read, params: { discussion_id: @discussion.id, topic_item_id: @topic_item.id, unsubscribe_token: @user.unsubscribe_token }
    reader = TopicReader.for(user: @user, topic: @topic)
    assert_in_delta @topic_item.created_at.to_f, reader.last_read_at.to_f, 1.0
  end

  test "does not error when discussion not found" do
    get :mark_discussion_as_read, params: { discussion_id: :notathing, topic_item_id: @topic_item.id, unsubscribe_token: @user.unsubscribe_token }
    assert_response 200
  end

  test "does not error when discussion has since been discarded" do
    notification = Notification.create!(
      actor: @author,
      kind: "new_discussion",
      subject: @discussion
    )
    delivery = NotificationDelivery.create!(notification: notification, recipient: @user, channel: "in_app", delivered_at: notification.created_at)
    TopicService.discard(topic: @topic, actor: @author)

    get :mark_discussion_as_read, params: {
      discussion_id: @discussion.id,
      topic_item_id: @topic_item.id,
      unsubscribe_token: @user.unsubscribe_token
    }

    assert_response 200
    assert_predicate delivery.reload, :viewed?
  end

  test "marks a comment as read" do
    comment_event = nil
    CommentService.create(comment: Comment.new(parent: @discussion, body: "hello"), actor: @author) { |created_topic_item| comment_event = created_topic_item }
    reader = TopicReader.for(user: @user, topic: @topic)
    refute reader.has_read?(comment_event.sequence_id)

    get :mark_discussion_as_read, params: { discussion_id: @discussion.id, topic_item_id: comment_event.id, unsubscribe_token: @user.unsubscribe_token }
    reader = TopicReader.for(user: @user, topic: @topic)
    assert_in_delta Time.now.to_f, reader.last_read_at.to_f, 2.0
    assert reader.has_read?(comment_event.sequence_id)
  end

  # mark_notification_as_read test
  test "marks notification as viewed" do
    notification = Notification.create!(
      actor: @author,
      kind: "new_discussion",
      subject: @discussion
    )
    delivery = NotificationDelivery.create!(notification: notification, recipient: @user, channel: "in_app", delivered_at: notification.created_at)
    get :mark_notification_as_read, params: { id: notification.id, unsubscribe_token: @user.unsubscribe_token }
    assert_predicate delivery.reload, :viewed?
  end

  test "marks only the authenticated recipient's global in-app delivery as viewed" do
    notification = Notification.create!(
      actor: @author,
      kind: "discussion_edited",
      subject: @discussion
    )
    user_delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: @user,
      channel: "in_app",
      delivered_at: Time.current
    )
    author_delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: @author,
      channel: "in_app",
      delivered_at: Time.current
    )

    get :mark_notification_as_read, params: {
      id: notification.id,
      unsubscribe_token: @user.unsubscribe_token
    }

    assert_response :success
    assert_not_nil user_delivery.reload.viewed_at
    assert_nil author_delivery.reload.viewed_at
  end

  test "marks digest notifications as viewed" do
    time_start = 1.hour.ago
    time_finish = Time.current
    included_notification = Notification.create!(
      actor: @author,
      kind: "discussion_edited",
      subject: @discussion,
      created_at: 30.minutes.ago
    )
    included_delivery = NotificationDelivery.create!(
      notification: included_notification,
      recipient: @user,
      channel: "in_app",
      delivered_at: included_notification.created_at
    )
    other_recipient_delivery = NotificationDelivery.create!(
      notification: included_notification,
      recipient: @author,
      channel: "in_app",
      delivered_at: included_notification.created_at
    )
    old_notification = Notification.create!(
      actor: @author,
      kind: "discussion_edited",
      subject: @discussion,
      created_at: 2.hours.ago
    )
    old_delivery = NotificationDelivery.create!(
      notification: old_notification,
      recipient: @user,
      channel: "in_app",
      delivered_at: old_notification.created_at
    )

    get :mark_digest_as_read, params: {
      time_start: time_start.to_i,
      time_finish: time_finish.to_i,
      unsubscribe_token: @user.unsubscribe_token
    }

    assert_response :redirect
    assert_predicate included_delivery.reload, :viewed?
    assert_not_predicate other_recipient_delivery.reload, :viewed?
    assert_not_predicate old_delivery.reload, :viewed?
  end

  # mark_digest_as_read test
  test "marks content as read" do
    time_start = 1.hour.ago
    comment = Comment.new(parent: @discussion, body: "summary test", created_at: time_start)
    CommentService.create(comment: comment, actor: @author)

    get :mark_digest_as_read, params: {
      time_start: time_start.to_i,
      time_finish: 30.minutes.ago.to_i,
      unsubscribe_token: @user.unsubscribe_token,
      format: :gif
    }
    assert_response 200
  end
end
