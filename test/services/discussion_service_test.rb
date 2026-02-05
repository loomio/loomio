require 'test_helper'

class DiscussionServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @group.add_member!(@user) unless @group.members.include?(@user)
    @group.add_member!(@another_user) unless @group.members.include?(@another_user)
    ActionMailer::Base.deliveries.clear
  end

  test "creates a discussion and returns an event" do
    discussion = Discussion.new(
      title: 'Test Discussion',
      description: 'Test description',
      group: @group,
      author: @user,
      private: true
    )

    event = DiscussionService.create(discussion: discussion, actor: @user)

    assert_kind_of Event, event
    assert discussion.persisted?
  end

  test "does not email people when creating discussion" do
    discussion = Discussion.new(
      title: 'Test Discussion',
      description: 'Test description',
      group: @group,
      author: @user
    )

    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      DiscussionService.create(discussion: discussion, actor: @user)
    end
  end

  test "notifies mentioned users in discussion description" do
    @another_user.update(username: 'mentionuser')

    discussion = Discussion.new(
      title: 'Test Discussion',
      description: "A mention for @mentionuser!",
      description_format: 'md',
      group: @group,
      author: @user
    )

    assert_difference "Event.where(kind: 'user_mentioned').count", 1 do
      DiscussionService.create(discussion: discussion, actor: @user)
    end
  end

  test "creates discussion reader for author" do
    discussion = Discussion.new(
      title: 'Test Discussion',
      description: 'Test description',
      group: @group,
      author: @user
    )

    DiscussionService.create(discussion: discussion, actor: @user)

    reader = DiscussionReader.for(user: @user, discussion: discussion)
    assert_not_nil reader
    assert_includes ['normal', 'loud'], reader.volume
  end

  test "updates a discussion" do
    discussion = create_discussion(group: @group, author: @user)

    DiscussionService.update(
      discussion: discussion,
      params: { title: 'Updated Title', description: 'Updated description' },
      actor: @user
    )

    assert_equal 'Updated Title', discussion.reload.title
    assert_equal 'Updated description', discussion.description
  end

  test "moves discussion to another group" do
    another_group = Group.create!(
      name: 'Another Group',
      handle: "anothergroup-#{SecureRandom.hex(4)}"
    )
    another_group.add_admin!(@user)

    discussion = create_discussion(group: @group, author: @user)

    DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: @user)

    assert_equal another_group, discussion.reload.group
  end

  test "does not move discussion without permission" do
    another_group = Group.create!(
      name: 'Another Group',
      handle: "anothergroup2-#{SecureRandom.hex(4)}",
      is_visible_to_public: false
    )

    discussion = create_discussion(group: @group, author: @user)

    assert_raises CanCan::AccessDenied do
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: @user)
    end
  end

  test "closes a discussion" do
    discussion = create_discussion(group: @group, author: @user)

    assert_nil discussion.closed_at

    DiscussionService.close(discussion: discussion, actor: @user)

    assert_not_nil discussion.reload.closed_at
  end

  test "reopens a closed discussion" do
    discussion = create_discussion(group: @group, author: @user)
    discussion.update(closed_at: 1.day.ago)

    DiscussionService.reopen(discussion: discussion, actor: @user)

    assert_nil discussion.reload.closed_at
  end
end
