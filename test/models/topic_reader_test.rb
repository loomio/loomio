require 'test_helper'

class TopicReaderTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)

    @discussion = discussions(:discussion)
    @membership = @admin.memberships.find_by(group: @group)
    @membership.update!(volume_email: :normal)
    @reader = TopicReader.for(user: @admin, topic: @discussion.topic)
  end

  test "guest and admin readers use user delivery defaults" do
    guest = User.create!(name: "Guest defaults", email: "guest-defaults-#{SecureRandom.hex(4)}@example.test", volume_email_default: :quiet, volume_push_default: :loud)
    admin = User.create!(name: "Admin defaults", email: "admin-defaults-#{SecureRandom.hex(4)}@example.test", volume_email_default: :loud, volume_push_default: :quiet)

    guest_reader = @discussion.topic.add_guest!(guest, @admin)
    admin_reader = @discussion.topic.add_admin!(admin, @admin)

    assert_predicate guest_reader, :email_quiet?
    assert_predicate guest_reader, :push_loud?
    assert_predicate admin_reader, :email_loud?
    assert_predicate admin_reader, :push_quiet?
  end

  test "guest invitation is not redeemable after the user joins the topic group" do
    guest = User.create!(name: "Guest becoming member", email: "guest-member-#{SecureRandom.hex(4)}@example.test")
    reader = @discussion.topic.add_guest!(guest, @admin)

    assert_includes TopicReader.redeemable, reader

    @group.add_member!(guest)

    refute_includes TopicReader.redeemable, reader
  end

  # Computed volume
  test "can change its volume" do
    @reader.set_volume!(email: :loud, push: :normal)
    assert_equal :loud, @reader.reload.volume_email.to_sym
  end

  test "defaults to the memberships volume when nil" do
    assert_equal @membership.volume_email, @reader.computed_volume_email
    assert_equal @membership.volume_push, @reader.computed_volume_push
  end

  test "topic delivery volume scopes require current access at every level" do
    levels = %i[quiet normal loud]
    users_by_access = Hash.new { |hash, key| hash[key] = {} }

    levels.each do |level|
      create_user = lambda do |access|
        token = SecureRandom.hex(5)
        User.create!(
          name: "#{access} #{level}",
          email: "#{access}-#{level}-#{token}@example.test",
          volume_email_default: level,
          volume_push_default: level
        )
      end

      member = create_user.call(:member)
      @group.add_member!(member).update!(volume_email: level, volume_push: level)
      member.update!(
        volume_email_default: level == :quiet ? :loud : :quiet,
        volume_push_default: level == :quiet ? :loud : :quiet
      )
      users_by_access[:member][level] = member

      guest = create_user.call(:guest)
      @discussion.topic.add_guest!(guest, @admin).update!(volume_email: level, volume_push: level)
      guest.update!(
        volume_email_default: level == :quiet ? :loud : :quiet,
        volume_push_default: level == :quiet ? :loud : :quiet
      )
      users_by_access[:guest][level] = guest

      unrelated = create_user.call(:unrelated)
      users_by_access[:unrelated][level] = unrelated

      non_guest_reader = create_user.call(:non_guest_reader)
      TopicReader.create!(
        user: non_guest_reader,
        topic: @discussion.topic,
        inviter: @admin,
        guest: false,
        volume_email: level,
        volume_push: level
      )
      users_by_access[:non_guest_reader][level] = non_guest_reader

      former_member = create_user.call(:former_member)
      @group.add_member!(former_member).update!(
        volume_email: level,
        volume_push: level,
        revoked_at: Time.current
      )
      users_by_access[:former_member][level] = former_member

      former_guest = create_user.call(:former_guest)
      @discussion.topic.add_guest!(former_guest, @admin).update!(
        volume_email: level,
        volume_push: level,
        revoked_at: Time.current
      )
      users_by_access[:former_guest][level] = former_guest
    end

    expectations = {
      email_enabled_members: %i[normal loud],
      email_normal_members: %i[normal],
      email_loud_members: %i[loud],
      push_enabled_members: %i[normal loud],
      push_loud_members: %i[loud]
    }

    expectations.each do |scope_name, included_levels|
      scope = @discussion.topic.public_send(scope_name)

      %i[member guest].each do |access|
        levels.each do |level|
          assertion = included_levels.include?(level) ? :assert_includes : :assert_not_includes
          public_send(assertion, scope, users_by_access[access][level], "#{scope_name} #{access} #{level}")
        end
      end

      %i[unrelated non_guest_reader former_member former_guest].each do |access|
        levels.each do |level|
          assert_not_includes scope, users_by_access[access][level], "#{scope_name} #{access} #{level}"
        end
      end
    end
  end

  test "direct topic delivery volume scopes use only active guests" do
    topic = @discussion.topic
    topic.update!(group_id: nil)

    loud_guest = User.create!(name: "Direct loud guest", email: "direct-loud-#{SecureRandom.hex(4)}@example.test")
    topic.add_guest!(loud_guest, @admin).update!(volume_email: :loud, volume_push: :loud)

    quiet_guest = User.create!(name: "Direct quiet guest", email: "direct-quiet-#{SecureRandom.hex(4)}@example.test")
    topic.add_guest!(quiet_guest, @admin).update!(volume_email: :quiet, volume_push: :quiet)

    former_guest = User.create!(name: "Direct former guest", email: "direct-former-#{SecureRandom.hex(4)}@example.test")
    topic.add_guest!(former_guest, @admin).update!(volume_email: :loud, volume_push: :loud, revoked_at: Time.current)

    non_guest_reader = User.create!(name: "Direct non-guest reader", email: "direct-reader-#{SecureRandom.hex(4)}@example.test")
    TopicReader.create!(
      user: non_guest_reader,
      topic: topic,
      inviter: @admin,
      guest: false,
      volume_email: :loud,
      volume_push: :loud
    )

    unrelated = User.create!(
      name: "Direct unrelated",
      email: "direct-unrelated-#{SecureRandom.hex(4)}@example.test",
      volume_email_default: :loud,
      volume_push_default: :loud
    )

    %i[email_enabled_members email_loud_members push_enabled_members push_loud_members].each do |scope_name|
      scope = topic.public_send(scope_name)
      assert_includes scope, loud_guest, scope_name
      assert_not_includes scope, quiet_guest, scope_name
      assert_not_includes scope, former_guest, scope_name
      assert_not_includes scope, non_guest_reader, scope_name
      assert_not_includes scope, unrelated, scope_name
    end
  end

  # Viewed
  test "updates counts correctly from existing last_read_at" do
    @reader.update!(last_read_at: 6.days.ago)

    comment1 = Comment.new(parent: @discussion, body: "Older", author: @admin)
    older_event = nil
    CommentService.create(comment: comment1, actor: @admin) { |created_topic_item| older_event = created_topic_item }

    comment2 = Comment.new(parent: @discussion, body: "Newer", author: @admin)
    newer_event = nil
    CommentService.create(comment: comment2, actor: @admin) { |created_topic_item| newer_event = created_topic_item }

    @reader.viewed!([newer_event, older_event].map(&:sequence_id))
    assert_equal 2, @reader.read_items_count
    assert @reader.last_read_at > 1.minute.ago
  end

  test "updates existing counts correctly" do
    @reader.update!(last_read_at: 6.days.ago)

    comment1 = Comment.new(parent: @discussion, body: "Older", author: @admin)
    older_event = nil
    CommentService.create(comment: comment1, actor: @admin) { |created_topic_item| older_event = created_topic_item }

    comment2 = Comment.new(parent: @discussion, body: "Newer", author: @admin)
    newer_event = nil
    CommentService.create(comment: comment2, actor: @admin) { |created_topic_item| newer_event = created_topic_item }

    @reader.viewed!(newer_event.sequence_id)
    assert_not @reader.has_read?(older_event.sequence_id)
    assert @reader.has_read?(newer_event.sequence_id)
    assert_equal 1, @reader.read_items_count
  end

  test "does not duplicate views" do
    @reader.update!(last_read_at: 6.days.ago)

    comment = Comment.new(parent: @discussion, body: "Older", author: @admin)
    topic_item = nil
    CommentService.create(comment: comment, actor: @admin) { |created_topic_item| topic_item = created_topic_item }

    @reader.viewed!(topic_item.sequence_id)
    assert_equal 1, @reader.read_items_count
    @reader.viewed!(topic_item.sequence_id)
    assert_equal 1, @reader.read_items_count
  end

  # has_read?
  test "nothing read yet returns false" do
    @reader.read_ranges_string = ''
    assert_not @reader.has_read?([[1, 1]])
  end

  test "has been read returns true" do
    @reader.read_ranges_string = '1-1'
    assert @reader.has_read?([[1, 1]])
  end

  test "has not been read returns false" do
    @reader.read_ranges_string = '1-1'
    assert_not @reader.has_read?([[1, 2]])
  end

  test "complex has_read" do
    @reader.read_ranges_string = '1-5,7-9'
    assert @reader.has_read?([[7, 8]])
    assert_not @reader.has_read?([[1, 3], [7, 10]])
  end

  # mark_as_read
  test "accepts single sequence_ids" do
    @reader.mark_as_read 1
    assert_equal "1-1", @reader.read_ranges_string
  end

  test "accepts arrays of sequence_ids" do
    @reader.mark_as_read [1, 2, 3]
    assert_equal "1-3", @reader.read_ranges_string
  end

  test "creates a range" do
    @reader.mark_as_read [1, 1]
    assert_equal "1-1", @reader.read_ranges_string
  end

  test "extends a range" do
    @reader.mark_as_read [1, 1]
    @reader.mark_as_read [2, 2]
    assert_equal "1-2", @reader.read_ranges_string
  end

  test "extends a range further" do
    @reader.mark_as_read [1, 1]
    @reader.mark_as_read [2, 2]
    @reader.mark_as_read [3, 3]
    assert_equal "1-3", @reader.read_ranges_string
  end

  test "handles complex mark_as_read" do
    @reader.mark_as_read [[1, 1], [2, 2], [3, 3], [1, 3], [6, 8], [6, 7], [10, 10]]
    assert_equal "1-3,6-8,10-10", @reader.read_ranges_string
  end
end
