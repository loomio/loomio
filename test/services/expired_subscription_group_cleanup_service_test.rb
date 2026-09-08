require "test_helper"
require "stringio"

class ExpiredSubscriptionGroupCleanupServiceTest < ActiveSupport::TestCase
  test "fixture matrix selects old expired trials and cancellations without overlapping empty trial deletion" do
    expected = groups(
      :used_canceled_free_group,
      :trial_cleanup_poll,
      :trial_cleanup_billing,
      :trial_cleanup_chargify,
      :trial_cleanup_shared,
      :trial_cleanup_shared_other,
      :trial_cleanup_child_subscription
    ).map(&:id).sort

    plan = ExpiredSubscriptionGroupCleanupService.audit

    assert_equal expected, plan[:groups].pluck(:group_id).sort
    reasons = plan[:groups].to_h { |entry| [entry[:group_id], entry[:reason]] }
    assert_equal "subscription_canceled", reasons.fetch(groups(:used_canceled_free_group).id)
    (expected - [groups(:used_canceled_free_group).id]).each do |group_id|
      assert_equal "trial_expired", reasons.fetch(group_id)
    end
    assert_not_includes expected, groups(:trial_cleanup_recent).id
    assert_not_includes expected, groups(:trial_cleanup_no_expiry).id
    assert_not_includes expected, groups(:trial_cleanup_discarded).id
  end

  test "eligibility starts sixty days after trial expiry or cancellation" do
    as_of = Time.current
    trial_group = groups(:trial_cleanup_recent)
    topics(:direct_topic).update!(group_id: trial_group.id)
    canceled_group = groups(:used_canceled_free_group)

    trial_group.subscription.update!(expires_at: as_of - 60.days + 1.second)
    canceled_group.subscription.update!(canceled_at: as_of - 60.days + 1.second)
    assert_not_includes ExpiredSubscriptionGroupCleanupService.audit(as_of: as_of)[:groups].pluck(:group_id), trial_group.id
    assert_not_includes ExpiredSubscriptionGroupCleanupService.audit(as_of: as_of)[:groups].pluck(:group_id), canceled_group.id

    trial_group.subscription.update!(expires_at: as_of - 60.days)
    canceled_group.subscription.update!(canceled_at: as_of - 60.days)
    assert_includes ExpiredSubscriptionGroupCleanupService.audit(as_of: as_of)[:groups].pluck(:group_id), trial_group.id
    assert_includes ExpiredSubscriptionGroupCleanupService.audit(as_of: as_of)[:groups].pluck(:group_id), canceled_group.id

    canceled_group.subscription.update!(canceled_at: nil)
    assert_not_includes ExpiredSubscriptionGroupCleanupService.audit(as_of: as_of)[:groups].pluck(:group_id), canceled_group.id
  end

  test "warns once, records the plan, and schedules exact deletion and email jobs" do
    plan = ExpiredSubscriptionGroupCleanupService.audit(limit: 1)
    group = Group.find(plan[:groups].first.fetch(:group_id))
    group.add_admin!(users(:admin))
    clear_enqueued_jobs
    io = StringIO.new

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      assert_enqueued_with(job: DestroyGroupWorker) do
        result = ExpiredSubscriptionGroupCleanupService.warn_and_schedule!(io: io, limit: 1)
        assert_equal({ warned_groups: 1, skipped_groups: 0 }, result)
      end
    end

    assert group.reload.discarded?
    assert_nil group.discarded_by
    assert_equal %w[plan warned complete], io.string.lines.map { |line| JSON.parse(line).fetch("type") }
    assert_empty ExpiredSubscriptionGroupCleanupService.audit[:groups].select { |entry| entry[:group_id] == group.id }
  end

  test "rechecks eligibility before warning" do
    original = ExpiredSubscriptionGroupCleanupService.method(:audit)
    replacement = lambda do |**args|
      plan = original.call(**args.merge(limit: 1))
      Group.find(plan[:groups].first.fetch(:group_id)).subscription.update!(expires_at: 1.year.from_now, state: "active", canceled_at: nil)
      plan
    end
    io = StringIO.new

    result = ExpiredSubscriptionGroupCleanupService.stub(:audit, replacement) do
      ExpiredSubscriptionGroupCleanupService.warn_and_schedule!(io: io)
    end

    assert_equal({ warned_groups: 0, skipped_groups: 1 }, result)
    assert io.string.lines.map { |line| JSON.parse(line) }.any? { |entry| entry["type"] == "skipped" }
  end

  test "subscription warning cannot discard active or permanent free groups" do
    [groups(:used_paid_group), groups(:orphan_group)].each do |group|
      assert_no_enqueued_jobs(only: DestroyGroupWorker) do
        assert_raises(CanCan::AccessDenied) do
          GroupService.warn_then_destroy_subscription(group: group, reason: "subscription_canceled")
        end
      end
      assert group.reload.kept?
    end
  end
end
