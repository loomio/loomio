require 'test_helper'

class DiscussionServiceTest < ActiveSupport::TestCase
  inline_jobs "notifies mentioned users in discussion description"
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
  end

  # -- Create --

  test "creates a discussion" do
    discussion = DiscussionService.create(params: {
      title: 'Test Discussion',
      description: 'Test description',
      group_id: @group.id,
      private: true
    }, actor: @user)

    assert_kind_of Discussion, discussion
    assert discussion.persisted?
    assert_kind_of Topic, discussion.topic
  end

  test "creates a public discussion when the group requires public discussions" do
    group = Group.create!(
      name: "Open Group #{SecureRandom.hex(4)}",
      group_privacy: 'open'
    )
    Membership.create!(user: @user, group: group, accepted_at: Time.current, admin: true)

    discussion = DiscussionService.create(
      params: { title: 'Public Discussion', group_id: group.id },
      actor: @user
    )

    assert group.public_discussions_only?
    assert_equal false, discussion.topic.private
  end

  test "raises a validation error when discussion privacy is not permitted by the group" do
    group = Group.create!(
      name: "Open Group #{SecureRandom.hex(4)}",
      group_privacy: 'open'
    )
    Membership.create!(user: @user, group: group, accepted_at: Time.current, admin: true)

    error = assert_raises ActiveRecord::RecordInvalid do
      DiscussionService.create(
        params: { title: 'Private Discussion', group_id: group.id, private: true },
        actor: @user
      )
    end

    assert_equal ['must be public'], error.record.errors[:private]
    assert_not error.record.persisted?
  end

  test "does not allow unauthorized user to create discussion" do
    assert_raises CanCan::AccessDenied do
      DiscussionService.create(params: {
        title: 'Unauthorized Discussion',
        description: 'Test',
        group_id: @group.id,
        private: true
      }, actor: @alien)
    end
  end

  test "creates a direct discussion with tags without raising" do
    discussion = DiscussionService.create(params: {
      title: 'Direct Discussion',
      description: 'Test description',
      tags: ['urgent']
    }, actor: @user)

    assert discussion.persisted?
    assert_nil discussion.group_id
    assert_equal ['urgent'], discussion.topic.tags
  end

  test "does not email people when creating discussion" do
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      DiscussionService.create(params: {
        title: 'Test Discussion',
        description: 'Test description',
        group_id: @group.id
      }, actor: @user)
    end
  end

  test "notifies mentioned users in discussion description" do
    @admin.update!(username: "mentionme#{SecureRandom.hex(4)}")

    assert_difference "Notification.where(kind: 'user_mentioned').count", 1 do
      DiscussionService.create(params: {
        title: 'Test Discussion',
        description: "A mention for @#{@admin.username}!",
        description_format: 'md',
        group_id: @group.id
      }, actor: @user)
    end
  end

  test "create leaves a newly mentioned explicit recipient to the mention notification" do
    recipient = users(:member)
    recipient.update!(username: "createmention#{SecureRandom.hex(4)}")

    discussion = DiscussionService.create(
      params: {
        title: "Mention notification",
        description: "Please review this, @#{recipient.username}",
        description_format: "md",
        group_id: @group.id,
        recipient_user_ids: [ recipient.id ]
      },
      actor: @user
    )
    notification = Notification.find_by!(kind: "new_discussion", subject: discussion.created_topic_item)

    assert_equal [ recipient.id ], notification.audience_values["newly_mentioned_user_ids"]
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_empty notification.notification_deliveries
    assert Notification.exists?(kind: "user_mentioned", subject: discussion.created_topic_item)
  end

  test "does not notify users outside the group" do
    assert_no_difference "Notification.where(kind: 'user_mentioned').count" do
      DiscussionService.create(params: {
        title: 'Test Discussion',
        description: "A mention for @#{@alien.username}!",
        description_format: 'md',
        group_id: @group.id
      }, actor: @user)
    end
  end

  test "creates discussion reader for author" do
    discussion = DiscussionService.create(params: {
      title: 'Test Discussion',
      description: 'Test description',
      group_id: @group.id
    }, actor: @user)

    reader = TopicReader.for(user: @user, topic: discussion.topic)
    assert_not_nil reader
    assert_includes ['normal', 'loud'], reader.volume_email
  end

  # -- Update --

  test "updates a discussion" do
    discussion = discussions(:discussion)
    DiscussionService.update(discussion: discussion, actor: @user, params: { title: 'New Title' })
    assert_equal 'New Title', discussion.reload.title
  end

  test "updating a discussion preserves its topic tags" do
    discussion = discussions(:discussion)
    discussion.topic.update!(tags: [ 'literature' ])

    discussion.stub(:update_versions_count, nil) do
      TopicItems::DiscussionEdited.stub(:create!, nil) do
        DiscussionService.update(
          discussion: discussion,
          actor: @user,
          params: { description: 'Updated context', tags: [] }
        )
      end
    end

    assert_equal [ 'literature' ], discussion.topic.reload.tags
  end

  test "update does not allow unauthorized user" do
    discussion = discussions(:discussion)

    assert_raises CanCan::AccessDenied do
      DiscussionService.update(discussion: discussion, actor: @alien, params: { title: 'Hacked' })
    end
  end

  test "update allows group admin to update" do
    discussion = discussions(:discussion)
    DiscussionService.update(discussion: discussion, actor: @admin, params: { title: 'Admin Updated' })
    assert_equal 'Admin Updated', discussion.reload.title
  end

  test "update cannot move a discussion to another group" do
    discussion = discussions(:discussion)
    destination = groups(:alien_group)

    DiscussionService.update(
      discussion: discussion,
      actor: @user,
      params: { title: 'Safe update', group_id: destination.id }
    )

    assert_equal @group.id, discussion.reload.group_id
    assert_equal 'Safe update', discussion.title
  end

  test "update keeps its history topic_item and creates one logical notification" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    TopicReader.for(user: recipient, topic: discussion.topic).set_volume!(email: :normal, push: :quiet)

    topic_item = DiscussionService.update(
      discussion: discussion,
      actor: @user,
      params: {
        title: "Notification-backed edit",
        recipient_user_ids: [ recipient.id ],
        recipient_message: "Please review the changes"
      }
    )
    notification = Notification.find_by!(kind: "discussion_edited", subject: topic_item)

    assert_equal "discussion_edited", topic_item.kind
    assert_equal discussion.topic_id, topic_item.topic_id
    assert_not_respond_to topic_item, :recipient_message
    assert_equal "TopicItem", notification.subject_type
    assert_equal topic_item.id, notification.subject_id
    assert_equal [ recipient.id ], notification.recipient_user_ids
    assert_equal "Please review the changes", notification.recipient_message
    assert_equal 1, Notification.where(kind: "discussion_edited", subject: topic_item).count

    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
  end

  test "update leaves a newly mentioned explicit recipient to the mention notification" do
    discussion = discussions(:discussion)
    recipient = users(:member)
    recipient.update!(username: "editmention#{SecureRandom.hex(4)}")
    TopicReader.for(user: recipient, topic: discussion.topic).set_volume!(email: :normal, push: :quiet)

    DiscussionService.update(
      discussion: discussion,
      actor: @user,
      params: {
        description: "Please review this, @#{recipient.username}",
        description_format: "md",
        recipient_user_ids: [ recipient.id ]
      }
    )
    notification = Notification.about(discussion).find_by!(kind: "discussion_edited")

    assert_equal [ recipient.id ], notification.audience_values["newly_mentioned_user_ids"]
    RouteNotificationDeliveriesWorker.perform_now(notification.id)
    assert_empty notification.notification_deliveries
    assert Notification.about(discussion).exists?(kind: "user_mentioned")
  end

  test "eventless update without a direct audience does not create a notification" do
    discussion = discussions(:discussion)

    assert_no_difference "TopicItem.where(kind: 'discussion_edited').count" do
      NotificationService.stub(:create!, ->(**) { raise "notification creation is not expected" }) do
        DiscussionService.update(
          discussion: discussion,
          actor: @user,
          params: { title: "Saved without a notification" }
        )
      end
    end

    assert_equal "Saved without a notification", discussion.reload.title
  end

  # -- Discard --

  test "discard marks discussion and polls as discarded" do
    discussion = discussions(:discussion)

    poll = PollService.create(params: {
      title: 'Test Poll',
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      group_id: @group.id,
      topic_id: discussion.topic_id,
      poll_option_names: ['agree', 'disagree']
    }, actor: @admin)

    DiscussionService.discard(discussion: discussion, actor: @admin)

    assert_not_nil discussion.reload.discarded_at
    assert_not_nil discussion.topic.reload.discarded_at
    assert_not_nil poll.reload.discarded_at
  end

end
