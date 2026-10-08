require 'test_helper'

class CounterColumnsTest < ActiveSupport::TestCase
  MEMBERSHIP_COUNTS_SQL = /FILTER \(WHERE accepted_at IS NULL\)/

  setup do
    @group = groups(:group)
    @admin = users(:admin)
  end

  test "membership changes recount the group's and user's counts once per transaction" do
    users = 3.times.map { create_user("counted") }

    assert_queries_match(MEMBERSHIP_COUNTS_SQL, count: 1) do
      Membership.transaction do
        users.each { |user| Membership.create!(group: @group, user: user, inviter: @admin) }
      end
    end

    assert_group_membership_counts(@group)
    users.each { |user| assert_equal 1, user.reload.memberships_count }
  end

  test "a rolled-back savepoint does not stop a later save from recounting" do
    discarded_user = create_user("rolledback")
    kept_user = create_user("kept")

    Membership.transaction do
      Membership.transaction(requires_new: true) do
        Membership.create!(group: @group, user: discarded_user, inviter: @admin)
        raise ActiveRecord::Rollback
      end
      Membership.create!(group: @group, user: kept_user, inviter: @admin)
    end

    assert_group_membership_counts(@group)
  end

  test "membership edits that do not affect counts do not recount" do
    membership = @group.memberships.find_by!(user: @admin)

    assert_no_queries_match(MEMBERSHIP_COUNTS_SQL) do
      membership.update!(title: "Treasurer", volume_email: :loud)
    end

    membership.update!(admin: !membership.admin)
    assert_group_membership_counts(@group)
  end

  test "revoking a member recounts pending and admin counts and the user's count" do
    user = create_user("revoked")
    @group.add_admin!(user)
    membership = @group.memberships.find_by!(user: user)

    MembershipService.revoke(membership: membership, actor: @admin)

    assert_group_membership_counts(@group)
    assert_equal user.memberships.count, user.reload.memberships_count
  end

  test "destroying a topic item recounts the parent that receives its children" do
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Counted replies" }, actor: @admin)
    parent = Comment.new(body: "parent", parent: discussion)
    CommentService.create(comment: parent, actor: @admin)
    reply = Comment.new(body: "reply", parent: parent)
    CommentService.create(comment: reply, actor: @admin)
    root_item = discussion.created_topic_item.reload
    parent_item = parent.created_topic_item.reload
    assert_equal 1, parent_item.child_count

    parent_item.destroy!

    assert_equal root_item.children.count, root_item.reload.child_count
  end

  test "discarding a subgroup or poll template recounts the group" do
    subgroup = groups(:subgroup)
    @group.update_subgroups_count
    subgroup.update!(discarded_at: Time.current)
    assert_equal @group.subgroups.count, @group.reload.subgroups_count

    template = PollTemplate.create!(title: "Counted", group: @group, process_name: "Counted", process_subtitle: "Counted", poll_type: "proposal", author: @admin)
    assert_equal @group.poll_templates.kept.count, @group.reload.poll_templates_count
    template.discard!(actor: @admin)
    assert_equal @group.poll_templates.kept.count, @group.reload.poll_templates_count
  end

  private

  def create_user(prefix)
    hex = SecureRandom.hex(4)
    User.create!(name: "#{prefix} #{hex}", email: "#{prefix}#{hex}@example.com", email_verified: true)
  end

  def assert_group_membership_counts(group)
    group.reload
    assert_equal group.memberships.count, group.memberships_count
    assert_equal group.memberships.pending.count, group.pending_memberships_count
    assert_equal group.admin_memberships.count, group.admin_memberships_count
  end
end
