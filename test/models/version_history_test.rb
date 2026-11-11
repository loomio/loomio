require "test_helper"

# Changes PaperTrail cannot see by itself: vote weights set with update_all,
# and poll options stored in their own table.
class VersionHistoryTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:user)
    @group = groups(:group)
    @poll = PollService.create(params: {
      title: "Weighted", poll_type: "proposal", closing_at: 3.days.from_now,
      group_id: @group.id, weighted_voting: true, poll_option_names: %w[Agree Disagree]
    }, actor: @admin)
  end

  def weight_change(version)
    version.object_changes.fetch("weight").map { |weight| BigDecimal(weight.to_s) }
  end

  test "membership weight changes are recorded with who made them" do
    membership = @group.memberships.find_by!(user: @user)
    other = @group.memberships.active.where.not(id: membership.id).first

    assert_difference -> { PaperTrail::Version.where(item_type: "Membership").count }, 1 do
      MembershipService.set_weights(group: @group, weights_by_membership_id: {membership.id.to_s => 2}, actor: @admin)
    end
    version = membership.versions.last
    assert_equal @admin.id, version.whodunnit
    assert_equal [1, 2], weight_change(version)

    MembershipService.reset_weights(group: @group, weight: 3, actor: @admin)
    assert_equal [2, 3], weight_change(membership.versions.last)
    assert_equal [1, 3], weight_change(other.versions.last)
  end

  test "unchanged weights are not recorded" do
    assert_no_difference -> { PaperTrail::Version.where(item_type: "Membership").count } do
      MembershipService.reset_weights(group: @group, weight: 1, actor: @admin)
    end
  end

  test "stance weight changes are recorded outside the vote's revision history" do
    stance = @poll.stances.latest.find_by!(participant: @user)

    StanceService.set_weight(stance: stance, weight: 2, actor: @admin)
    StanceService.reset_weights(poll: @poll, actor: @admin, mode: "value", weight: 4)

    weight_versions = PaperTrail::Version.where(item_type: "Stance", item_id: stance.id, event: Stance::WEIGHT_EVENT).order(:id)
    assert_equal [[1, 2], [2, 4]], weight_versions.map { |version| weight_change(version) }
    assert_equal [@admin.id], weight_versions.map(&:whodunnit).uniq
    assert_empty stance.versions.where(event: Stance::WEIGHT_EVENT)
    stance.save!
    vote_versions = PaperTrail::Version.where(item_type: "Stance", item_id: stance.id).where.not(event: Stance::WEIGHT_EVENT)
    assert_equal vote_versions.count, stance.reload.versions_count
  end

  test "resetting stance weights from memberships and turning weights off are recorded" do
    stance = @poll.stances.latest.find_by!(participant: @user)
    @group.memberships.find_by!(user: @user).update_columns(weight: 5)
    scope = PaperTrail::Version.where(item_type: "Stance", item_id: stance.id, event: Stance::WEIGHT_EVENT)

    StanceService.reset_weights(poll: @poll, actor: @admin, mode: "membership")
    assert_equal [1, 5], weight_change(scope.order(:id).last)
    assert_equal @admin.id, scope.order(:id).last.whodunnit

    PaperTrail.request(whodunnit: @admin.id) { @poll.reload.update!(weighted_voting: false) }
    assert_equal [5, 1], weight_change(scope.order(:id).last)
    assert_equal @admin.id, scope.order(:id).last.whodunnit
  end

  test "poll option changes are added to the version for that edit" do
    poll = PollService.create(params: {
      title: "Options", poll_type: "poll", closing_at: nil, group_id: @group.id,
      poll_option_names: %w[Red Blue]
    }, actor: @admin)

    PollService.update(poll: poll, params: {title: "Colours", poll_option_names: %w[Red Green]}, actor: @admin)
    version = poll.reload.versions.last
    assert_equal ["Options", "Colours"], version.object_changes["title"]
    assert_equal [%w[Red Blue], %w[Red Green]], version.object_changes["poll_option_names"]

    assert_difference -> { poll.reload.versions.count }, 1 do
      PollService.update(poll: poll, params: {poll_option_names: %w[Red Green Yellow]}, actor: @admin)
    end
    version = poll.reload.versions.last
    assert_equal [%w[Red Green], %w[Red Green Yellow]], version.object_changes["poll_option_names"]
    assert_equal poll.versions.count, poll.versions_count

    assert_no_difference -> { poll.reload.versions.count } do
      PollService.update(poll: poll, params: {poll_option_names: %w[Red Green Yellow]}, actor: @admin)
    end
  end

  test "poll voting rules are versioned" do
    PollService.update(poll: @poll, params: {quorum_pct: 40, agree_target: 60}, actor: @admin)
    changes = @poll.reload.versions.last.object_changes
    assert_equal [nil, 40], changes["quorum_pct"]
    assert_equal [nil, 60], changes["agree_target"]
  end
end
