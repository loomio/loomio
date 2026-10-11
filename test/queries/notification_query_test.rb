require "test_helper"

class NotificationQueryTest < ActiveSupport::TestCase
  test "batched authorization preserves group and direct access for discussions comments and reactions" do
    [:discussion_topic, :direct_topic].each do |fixture|
      topic = topics(fixture)
      discussion = topic.topicable
      discussion.create_missing_created_topic_item! unless discussion.created_topic_item
      comment = CommentService.create(comment: Comment.new(parent: discussion, body: "Notification access"), actor: users(:guest_normal))
      reaction = Reaction.create!(reactable: comment, user: users(:admin), reaction: "🙂")
      notifications = [discussion, discussion.created_topic_item, comment, comment.created_topic_item, reaction].map do |subject|
        Notification.create!(kind: "discussion_edited", actor: users(:admin), subject: subject)
      end
      roles = {
        admin: fixture == :discussion_topic,
        member_normal: fixture == :discussion_topic,
        guest_normal: true,
        guest_admin_normal: true,
        member_guest_loud: fixture == :discussion_topic,
        former_member_guest: fixture == :discussion_topic,
        alien_loud: false,
        non_guest_loud: false,
        former_member_loud: false,
        former_guest_loud: false,
        inactive_member_loud: false,
        inactive_guest_loud: false,
        server_admin: false
      }
      roles.each do |role, visible|
        result = accessible_ids(users(role), notifications)
        assert_equal visible ? notifications.map(&:id) : [], result, "#{fixture} #{role}"
      end
      assert_empty accessible_ids(LoggedOutUser.new, notifications)
      assert_equal notifications.map(&:id), accessible_ids(
        LoggedOutUser.new(params: {topic_reader_token: topic_readers(fixture == :direct_topic ? :direct_guest_normal_reader : :guest_normal_reader).token}),
        notifications
      )
      comment.update!(discarded_at: Time.current)
      assert_equal notifications.first(2).map(&:id), accessible_ids(users(:guest_normal), notifications)
      if topic.group_id
        topic.group.discard!
        assert_empty accessible_ids(users(:guest_normal), notifications)
        assert_empty accessible_ids(users(:admin), notifications)
      end
    end
  end

  test "batched authorization retains poll access for reactions on standalone poll comments" do
    poll = PollService.create(params: {
      title: "Private poll notifications", poll_type: "poll", private: true,
      group_id: groups(:group).id, closing_at: 5.days.from_now,
      poll_option_names: ["Agree"]
    }, actor: users(:admin))
    comment = CommentService.create(comment: Comment.new(parent: poll, body: "Poll comment"), actor: users(:admin))
    reaction = Reaction.create!(reactable: comment, user: users(:admin), reaction: "🙂")
    notifications = [poll, comment, reaction].map do |subject|
      Notification.create!(kind: "discussion_edited", actor: users(:admin), subject: subject)
    end

    assert_equal notifications.map(&:id), accessible_ids(users(:member_normal), notifications)
    assert_empty accessible_ids(users(:alien_loud), notifications)
    poll.update!(discarded_at: Time.current)
    assert_empty accessible_ids(users(:member_normal), notifications)
  end

  test "operational notification subjects retain their own authorization" do
    subject = ReceivedEmail.create!(group: groups(:group), headers: {}, body_text: "Unknown sender")
    notification = Notification.create!(kind: "discussion_edited", actor: users(:admin), subject: subject)

    assert_equal [notification.id], accessible_ids(users(:admin), [notification])
    assert_empty accessible_ids(users(:member_normal), [notification])
  end

  private

  def accessible_ids(user, notifications)
    NotificationQuery.currently_accessible_to(
      user: user, notifications: Notification.where(id: notifications.map(&:id)).includes(:subject).order(:id)
    ).map(&:id)
  end
end
