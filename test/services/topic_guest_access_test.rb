require 'test_helper'

class TopicGuestAccessTest < ActiveSupport::TestCase
  setup do
    @topic = topics(:discussion_topic)
    @admin = users(:admin)
    @destination = groups(:subgroup)
  end

  test 'inviting a non-guest reader grants commenting access without changing preferences or history' do
    reader = topic_readers(:non_guest_loud_reader)
    reader.update!(last_read_at: 1.hour.ago, read_ranges_string: '0-0', admin: true)
    preserved = reader.attributes.slice('volume_email', 'volume_push', 'last_read_at', 'read_ranges_string', 'admin', 'token')
    refute reader.user.can?(:create, Comment.new(parent: @topic.topicable))

    invite(reader.user)

    assert reader.reload.guest?
    assert_nil reader.revoked_at
    assert_equal @admin.id, reader.inviter_id
    assert_equal preserved, reader.attributes.slice(*preserved.keys)
    assert reader.user.can?(:create, Comment.new(parent: @topic.topicable))
  end

  test 'reinviting a revoked guest renews access without resetting delivery preferences' do
    reader = topic_readers(:former_guest_loud_reader)
    reader.update!(accepted_at: 2.days.ago)
    invite(reader.user)

    assert reader.reload.guest?
    assert_nil reader.revoked_at
    assert_nil reader.revoker_id
    assert_nil reader.accepted_at
    assert_equal @admin.id, reader.inviter_id
    assert_equal 'loud', reader.volume_email
    assert reader.user.can?(:create, Comment.new(parent: @topic.topicable))
  end

  test 'notifying existing guests and members preserves their roles and acceptance' do
    guest = topic_readers(:guest_normal_reader)
    member = topic_readers(:reader_normal_reader)
    guest.update!(accepted_at: 1.day.ago)
    preserved = guest.attributes.slice('guest', 'accepted_at', 'inviter_id', 'volume_email', 'volume_push')
    member_preferences = member.attributes.slice('volume_email', 'volume_push')

    invite(guest.user, member.user)

    assert_equal preserved, guest.reload.attributes.slice(*preserved.keys)
    refute member.reload.guest?
    assert_equal member_preferences, member.attributes.slice(*member_preferences.keys)
  end

  test 'a member without guest invitation permission cannot upgrade a reader' do
    groups(:group).update!(members_can_add_guests: false)
    reader = topic_readers(:non_guest_loud_reader)
    before = reader.attributes

    assert_raises(CanCan::AccessDenied) { invite(reader.user, actor: users(:member_normal)) }

    assert_equal before, reader.reload.attributes
  end

  test 'move preview counts people losing participation even when parent visibility permits reading' do
    @destination.update!(is_visible_to_parent_members: true, parent_members_can_see_discussions: true)
    @destination.add_member!(users(:member_normal))

    preview = TopicService.move_access(topic: @topic, params: {group_id: @destination.id}, actor: @admin)

    assert_equal 6, preview[:members_losing_access_count]
    assert preview[:can_retain_members_as_guests]
    assert_equal groups(:group).id, @topic.reload.group_id
    refute topic_readers(:reader_loud_reader).reload.guest?
  end

  test 'moving can retain former members as guests including existing non-guest readers' do
    @destination.update!(is_visible_to_parent_members: true, parent_members_can_see_discussions: true)
    reader = topic_readers(:reader_quiet_reader)
    preserved = reader.attributes.slice('volume_email', 'volume_push', 'read_ranges_string', 'token')

    assert_no_difference -> { Notification.count } do
      assert_no_difference -> { ActionMailer::Base.deliveries.count } do
        TopicService.move(topic: @topic, params: {group_id: @destination.id, retain_members_as_guests: true}, actor: @admin)
      end
    end

    assert reader.reload.guest?
    assert_equal preserved, reader.attributes.slice(*preserved.keys)
    assert users(:member).can?(:create, Comment.new(parent: @topic.topicable))
    assert users(:reader_quiet).can?(:create, Comment.new(parent: @topic.topicable))
    refute @topic.topic_readers.guests.exists?(user: users(:former_member_loud))
    refute @topic.topic_readers.guests.exists?(user: users(:inactive_member_loud))
    refute @topic.topic_readers.guests.exists?(user: users(:non_guest_loud))
    assert topic_readers(:guest_normal_reader).reload.guest?
    assert users(:member_guest_loud).can?(:create, Comment.new(parent: @topic.topicable))
    refute @topic.topic_readers.guests.exists?(user: users(:admin))
  end

  test 'moving without retention leaves former members read-only and keeps existing guests' do
    @destination.update!(is_visible_to_parent_members: true, parent_members_can_see_discussions: true)

    TopicService.move(topic: @topic, params: {group_id: @destination.id, retain_members_as_guests: 'false'}, actor: @admin)

    assert TopicQuery.visible_to(user: users(:reader_normal), topic_id: @topic.id).exists?
    refute users(:reader_normal).can?(:create, Comment.new(parent: @topic.topicable))
    assert users(:guest_normal).can?(:create, Comment.new(parent: @topic.topicable))
    refute topic_readers(:reader_normal_reader).reload.guest?
  end

  test 'retaining members requires guest permission in the destination and rolls back the move' do
    @destination.update!(members_can_add_guests: false)
    memberships(:admin_subgroup_membership).update!(admin: false)
    preview = TopicService.move_access(topic: @topic, params: {group_id: @destination.id}, actor: @admin)
    refute preview[:can_retain_members_as_guests]
    before = @topic.topic_readers.order(:id).pluck(:id, :guest, :revoked_at)

    assert_raises(CanCan::AccessDenied) do
      TopicService.move(topic: @topic, params: {group_id: @destination.id, retain_members_as_guests: true}, actor: @admin)
    end

    assert_equal groups(:group).id, @topic.reload.group_id
    assert_equal before, @topic.topic_readers.order(:id).pluck(:id, :guest, :revoked_at)
  end

  test 'failed move event creation rolls back retained guest access and the destination' do
    before = @topic.topic_readers.order(:id).pluck(:id, :guest, :inviter_id)
    TopicItems::DiscussionMoved.stub(:create!, ->(**) { raise 'event failed' }) do
      assert_raises(RuntimeError) do
        TopicService.move(topic: @topic, params: {group_id: @destination.id, retain_members_as_guests: true}, actor: @admin)
      end
    end
    assert_equal groups(:group).id, @topic.reload.group_id
    assert_equal before, @topic.topic_readers.order(:id).pluck(:id, :guest, :inviter_id)
  end

  test 'a subscription that disallows guests cannot retain members during a move' do
    subscription = subscriptions(:cleanup_active_paid)
    subscription.update!(allow_guests: false)
    groups(:group).update!(subscription: subscription)
    preview = TopicService.move_access(topic: @topic, params: {group_id: @destination.id}, actor: @admin)
    refute preview[:can_retain_members_as_guests]

    assert_raises(CanCan::AccessDenied) do
      TopicService.move(topic: @topic, params: {group_id: @destination.id, retain_members_as_guests: true}, actor: @admin)
    end

    assert_equal groups(:group).id, @topic.reload.group_id
    refute topic_readers(:reader_normal_reader).reload.guest?
  end

  test 'move preview and retention require source and destination permissions' do
    assert_raises(CanCan::AccessDenied) do
      TopicService.move_access(topic: @topic, params: {group_id: @destination.id}, actor: users(:member_normal))
    end
    assert_raises(CanCan::AccessDenied) do
      TopicService.move_access(topic: @topic, params: {group_id: groups(:alien_group).id}, actor: @admin)
    end
    assert_raises(CanCan::AccessDenied) do
      TopicService.move(topic: @topic, params: {group_id: @destination.id, retain_members_as_guests: true}, actor: users(:member_normal))
    end
  end

  private

  def invite(*people, actor: @admin)
    TopicService.invite(topic: @topic, actor: actor, params: {recipient_emails: people.map(&:email)})
  end
end
