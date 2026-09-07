require "test_helper"
require_relative "../support/access_volume_matrix"

class TrialCleanupServiceTest < ActiveSupport::TestCase
  include AccessVolumeMatrix

  setup do
    @creator = users(:member_quiet)
    @expires_before = Time.current
  end

  test "uses subscription expiry rather than group creation for the retention period" do
    old_group = create_trial_group(name: "Old group, recent expiry", created_at: 5.years.ago, expires_at: 59.days.ago)
    recent_group = create_trial_group(name: "Recent group, old expiry", created_at: 30.days.ago, expires_at: 61.days.ago)

    assert_not_includes candidates, old_group
    assert_includes candidates, recent_group
  end

  test "only includes trial groups" do
    trial = create_trial_group(name: "Expired trial", expires_at: 61.days.ago)
    free = create_group(name: "Free group", subscription: create_subscription(plan: "free", expires_at: 61.days.ago))
    paid = create_group(name: "Paid group", subscription: create_subscription(plan: "2024-starter-monthly", expires_at: 61.days.ago))

    assert_includes candidates, trial
    assert_not_includes candidates, free
    assert_not_includes candidates, paid
  end

  test "deletes an untouched expired trial tree immediately" do
    root = create_trial_group(name: "Unused trial", expires_at: 61.days.ago)
    subgroup = create_group(name: "Unused subgroup", parent: root)
    before = access_volume_matrix

    assert_equal :deleted, TrialCleanupService.cleanup_group!(root.id)

    assert_not Group.exists?(root.id)
    assert_not Group.exists?(subgroup.id)
    assert_access_volume_matrix_unchanged(before)
  end

  test "warns administrators and schedules used trials for deletion" do
    root = create_trial_group(name: "Used trial", expires_at: 61.days.ago)
    root.add_admin!(@creator)
    DiscussionService.create(params: { group_id: root.id, title: "Existing work" }, actor: @creator)

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      assert_enqueued_with(job: DestroyGroupWorker, args: ->(args) { args == [ root.id, root.reload.archived_at.iso8601(6) ] }) do
        assert_equal :warned, TrialCleanupService.cleanup_group!(root.id)
      end
    end

    assert root.reload.archived_at
    assert Group.exists?(root.id)
  end

  test "preserves a used trial that is restored before its scheduled deletion" do
    root = create_trial_group(name: "Restored used trial", expires_at: 61.days.ago)
    root.add_admin!(@creator)
    DiscussionService.create(params: { group_id: root.id, title: "Existing work" }, actor: @creator)
    TrialCleanupService.cleanup_group!(root.id)
    archived_at = root.reload.archived_at.iso8601(6)
    root.unarchive!

    DestroyGroupWorker.perform_now(root.id, archived_at)

    assert Group.exists?(root.id)
  end

  test "treats historical activity anywhere in the group tree as use" do
    matrix = build_group_matrix
    unused_ids = TrialCleanupService.unused_groups(expires_before: @expires_before)
                                    .where(id: matrix.values.pluck(:root).map(&:id)).pluck(:id)

    matrix.each do |name, entry|
      assert_equal entry[:unused], unused_ids.include?(entry[:root].id), name
      assert_not_includes unused_ids, entry[:subgroup].id, "#{name} subgroup must never be selected separately" if entry[:subgroup]
    end
  end

  test "cleanup is idempotent" do
    root = create_trial_group(name: "One-time cleanup", expires_at: 61.days.ago)

    assert_equal :deleted, TrialCleanupService.cleanup_group!(root.id)
    assert_nil TrialCleanupService.cleanup_group!(root.id)
  end

  private

  def candidates
    TrialCleanupService.eligible_groups(expires_before: 60.days.ago).to_a
  end

  def create_subscription(plan:, expires_at:)
    Subscription.create!(owner: @creator, plan: plan, expires_at: expires_at)
  end

  def create_trial_group(name:, expires_at:, created_at: 2.years.ago)
    create_group(
      name: name,
      subscription: create_subscription(plan: "trial", expires_at: expires_at),
      created_at: created_at
    )
  end

  def create_group(name:, subscription: nil, parent: nil, created_at: 2.years.ago)
    Group.create!(
      name: "#{name} #{SecureRandom.hex(4)}",
      creator: @creator,
      parent: parent,
      subscription: subscription,
      group_privacy: "secret",
      created_at: created_at
    )
  end

  def build_group_matrix
    matrix = {
      empty_tree: { root: groups(:orphan_group_tree), subgroup: groups(:orphan_subgroup), unused: true },
      active_topic: { root: groups(:used_topic_group), unused: false },
      discarded_topic: { root: groups(:used_discarded_topic_tree), subgroup: groups(:used_discarded_topic_subgroup), unused: false },
      revoked_membership: { root: groups(:used_revoked_membership_tree), subgroup: groups(:used_revoked_membership_subgroup), unused: false },
      multiple_users: { root: groups(:used_multiple_members_group), unused: false },
      discussion_template: { root: groups(:used_discussion_template_group), unused: false },
      poll_template: { root: groups(:used_poll_template_group), unused: false },
      membership_request: { root: groups(:used_membership_request_group), unused: false },
      chatbot: { root: groups(:used_chatbot_group), unused: false },
      tag: { root: groups(:used_tag_group), unused: false },
      attachment: { root: groups(:used_attachment_group), unused: false }
    }
    matrix.each_value do |entry|
      subscription = create_subscription(plan: "trial", expires_at: 61.days.ago)
      entry[:root].update_column(:subscription_id, subscription.id)
    end
    matrix
  end
end
