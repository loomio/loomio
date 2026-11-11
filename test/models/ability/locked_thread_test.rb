require "test_helper"

# A locked thread is archived as it is: nobody can edit it, add an outcome,
# or notify or invite anyone from it. Thread admins can unlock it.
class Ability::LockedThreadTest < ActiveSupport::TestCase
  setup do
    @topic = topics(:discussion_topic)
    @topic.group.update!(members_can_announce: true)
    @group_admin = users(:admin)
    @thread_admin = users(:member_normal)
    @topic.add_admin!(@thread_admin, @group_admin)
    @poll = PollService.create(params: {
      title: "Locked notify", poll_type: "proposal", poll_option_names: %w[Agree Disagree],
      closing_at: 3.days.from_now, topic_id: @topic.id, notify_on_open: false
    }, actor: @group_admin)
  end

  test "group and thread admins can notify from an unlocked thread" do
    [@group_admin, @thread_admin].each do |user|
      assert user.can?(:announce, @topic), user.name
      assert user.can?(:announce, @topic.topicable), user.name
      assert user.can?(:remind, @poll), user.name
    end
    assert @group_admin.can?(:announce, @poll)
  end

  test "nobody can announce or remind from a locked thread" do
    @topic.update_columns(locked_at: 1.hour.ago)
    @poll.reload
    [@group_admin, @thread_admin].each do |user|
      assert_not user.can?(:announce, @topic), user.name
      assert_not user.can?(:announce, @topic.reload.topicable), user.name
      assert_not user.can?(:announce, @poll), user.name
      assert_not user.can?(:remind, @poll), user.name
    end
  end

  test "nobody can invite people to a locked thread" do
    Subscription.for!(@topic.group).update_columns(allow_guests: true)
    assert @group_admin.can?(:add_members, @topic)
    assert @group_admin.can?(:add_guests, @topic)

    @topic.update_columns(locked_at: 1.hour.ago)
    @topic.reload
    [@group_admin, @thread_admin].each do |user|
      assert_not user.can?(:add_members, @topic), user.name
      assert_not user.can?(:add_guests, @topic), user.name
    end
  end

  test "outcomes of polls in a locked thread cannot be announced" do
    PollService.close(poll: @poll, actor: @group_admin)
    outcome = Outcome.create!(poll: @poll.reload, author: @group_admin, statement: "Done")
    assert @group_admin.can?(:announce, outcome)

    @topic.update_columns(locked_at: 1.hour.ago)
    assert_not @group_admin.can?(:announce, outcome.reload)
  end

  test "nobody can edit a locked thread or add an outcome, but thread admins can unlock it" do
    PollService.close(poll: @poll, actor: @group_admin)
    @topic.update_columns(locked_at: 1.hour.ago)
    discussion = @topic.reload.topicable
    @poll.reload

    [@group_admin, @thread_admin].each do |user|
      assert_not user.can?(:update, discussion), user.name
      assert_not user.can?(:create, Outcome.new(poll: @poll, author: user)), user.name
    end
    assert_raises(CanCan::AccessDenied) do
      DiscussionService.update(discussion: discussion, actor: @thread_admin, params: {title: "Edited"})
    end

    TopicService.unlock(topic: @topic, actor: @thread_admin)
    assert @thread_admin.can?(:update, @topic.reload.topicable)
  end
end
