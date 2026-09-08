require "test_helper"
require "stringio"

class ExpiredTrialGroupCleanupServiceTest < ActiveSupport::TestCase
  test "fixture matrix selects old expired trials without overlapping empty trial deletion" do
    expected = [groups(:trial_cleanup_poll).id]

    plan = ExpiredTrialGroupCleanupService.audit

    assert_equal expected, plan[:groups].pluck(:group_id).sort
    assert plan[:groups].all? { |entry| entry[:reason] == "trial_expired" }
    assert_not_includes expected, groups(:trial_cleanup_recent).id
    assert_not_includes expected, groups(:trial_cleanup_no_expiry).id
    assert_not_includes expected, groups(:trial_cleanup_discarded).id
    assert_not_includes plan[:groups].pluck(:group_id), groups(:trial_cleanup_billing).id
    assert_not_includes plan[:groups].pluck(:group_id), groups(:trial_cleanup_chargify).id
    assert_not_includes plan[:groups].pluck(:group_id), groups(:trial_cleanup_shared).id
    assert_not_includes plan[:groups].pluck(:group_id), groups(:trial_cleanup_child_subscription).id
  end

  test "eligibility starts sixty days after trial expiry" do
    as_of = Time.current
    trial_group = groups(:trial_cleanup_recent)
    topics(:direct_topic).update!(group_id: trial_group.id)
    trial_group.subscription.update!(expires_at: as_of - 60.days + 1.second)
    assert_not_includes ExpiredTrialGroupCleanupService.audit(as_of: as_of)[:groups].pluck(:group_id), trial_group.id

    trial_group.subscription.update!(expires_at: as_of - 60.days)
    assert_includes ExpiredTrialGroupCleanupService.audit(as_of: as_of)[:groups].pluck(:group_id), trial_group.id
  end

  test "cancelled subscriptions are excluded" do
    assert_not_includes ExpiredTrialGroupCleanupService.audit[:groups].pluck(:group_id), groups(:used_canceled_free_group).id
  end

  test "warns once, records the plan, and schedules exact deletion and email jobs" do
    plan = ExpiredTrialGroupCleanupService.audit(limit: 1)
    group = Group.find(plan[:groups].first.fetch(:group_id))
    group.add_admin!(users(:admin))
    clear_enqueued_jobs
    io = StringIO.new

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      assert_enqueued_with(job: DestroyGroupWorker) do
        result = ExpiredTrialGroupCleanupService.warn_and_schedule!(io: io, limit: 1)
        assert_equal({ warned_groups: 1, skipped_groups: 0 }, result)
      end
    end

    assert group.reload.discarded?
    assert_nil group.discarded_by
    assert_equal %w[plan warned complete], io.string.lines.map { |line| JSON.parse(line).fetch("type") }
    assert_empty ExpiredTrialGroupCleanupService.audit[:groups].select { |entry| entry[:group_id] == group.id }
  end

  test "rechecks eligibility before warning" do
    original = ExpiredTrialGroupCleanupService.method(:audit)
    replacement = lambda do |**args|
      plan = original.call(**args.merge(limit: 1))
      Group.find(plan[:groups].first.fetch(:group_id)).subscription.update!(expires_at: 1.year.from_now)
      plan
    end
    io = StringIO.new

    result = ExpiredTrialGroupCleanupService.stub(:audit, replacement) do
      ExpiredTrialGroupCleanupService.warn_and_schedule!(io: io)
    end

    assert_equal({ warned_groups: 0, skipped_groups: 1 }, result)
    assert io.string.lines.map { |line| JSON.parse(line) }.any? { |entry| entry["type"] == "skipped" }
  end

  test "expired trial warning cannot discard active, cancelled, or permanent free groups" do
    [groups(:used_paid_group), groups(:used_canceled_free_group), groups(:orphan_group)].each do |group|
      assert_no_enqueued_jobs(only: DestroyGroupWorker) do
        assert_raises(CanCan::AccessDenied) do
          GroupService.warn_then_destroy_expired_trial(group: group)
        end
      end
      assert group.reload.kept?
    end
  end
end
