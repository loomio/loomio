require 'test_helper'

class DiscussionServiceTest < ActiveSupport::TestCase
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

    assert_difference "Event.where(kind: 'user_mentioned').count", 1 do
      DiscussionService.create(params: {
        title: 'Test Discussion',
        description: "A mention for @#{@admin.username}!",
        description_format: 'md',
        group_id: @group.id
      }, actor: @user)
    end
  end

  test "does not notify users outside the group" do
    assert_no_difference "Event.where(kind: 'user_mentioned').count" do
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
    assert_includes ['normal', 'loud'], reader.volume
  end

  # -- Update --

  test "updates a discussion" do
    discussion = discussions(:discussion)
    DiscussionService.update(discussion: discussion, actor: @user, params: { title: 'New Title' })
    assert_equal 'New Title', discussion.reload.title
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
    assert_not_nil poll.reload.discarded_at
  end

  # -- Move --

  test "move moves discussion to a public_only group" do
    public_group = groups(:public_group)
    public_group.add_member!(@admin)

    discussion = discussions(:discussion)
    TopicService.move(topic: discussion.topic, params: { group_id: public_group.id }, actor: @admin)
    assert_equal false, discussion.topic.reload.private
  end

  test "move updates privacy for private_only groups" do
    public_group = groups(:public_group)
    public_group.add_admin!(@admin)
    subgroup = groups(:subgroup)

    discussion = DiscussionService.create(params: { title: "Test", group_id: public_group.id, private: false }, actor: @admin)
    assert_equal false, discussion.topic.private
    TopicService.move(topic: discussion.topic, params: { group_id: subgroup.id }, actor: @admin)
    assert_equal true, discussion.topic.reload.private
  end

  test "move updates topic group" do
    alien_group = groups(:alien_group)
    alien_group.add_member!(@admin)

    discussion = discussions(:discussion)
    TopicService.move(topic: discussion.topic, params: { group_id: alien_group.id }, actor: @admin)
    assert_equal alien_group.id, discussion.topic.reload.group_id
  end

  # -- Close / Reopen --

  test "closes a discussion" do
    discussion = DiscussionService.create(params: {
      title: 'Closeable Discussion',
      group_id: @group.id
    }, actor: @user)

    assert_nil discussion.topic.closed_at
    TopicService.close(topic: discussion.topic, actor: @user)
    assert_not_nil discussion.topic.reload.closed_at
  end

  test "reopens a closed discussion" do
    discussion = DiscussionService.create(params: {
      title: 'Reopenable Discussion',
      group_id: @group.id
    }, actor: @user)
    discussion.topic.update!(closed_at: 1.day.ago)

    TopicService.reopen(topic: discussion.topic, actor: @user)
    assert_nil discussion.topic.reload.closed_at
  end
end
