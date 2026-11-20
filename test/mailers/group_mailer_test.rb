require "test_helper"

class GroupMailerTest < ActionMailer::TestCase
  test "deletion warning includes usage and recovery instructions" do
    group = groups(:trial_cleanup_poll)
    recipient = users(:admin)
    usage = GroupUsageSummary.for(group)

    email = GroupMailer.expired_trial_deletion_warning(group.id, recipient.id)
    body = AppConfig.stub(:discarded_group_deletion_after_days, 45) { email.body.decoded }

    assert_equal "Your Loomio group is scheduled for deletion", email.subject
    assert_includes body, "trial expired 60 days ago"
    assert_includes body, "may be permanently deleted once it has been unavailable for 45 days"
    assert_includes body, "Your group is unavailable while it is marked for deletion"
    assert_includes body, "it is not too late to restart"
    assert_includes body, "Reply to this email immediately"
    assert_includes body, "request a trial extension, upgrade to a paid subscription"
    assert_includes body, "or need more time to export its data"
    assert_includes body, "Subgroups: #{usage[:subgroups]}"
    assert_includes body, "Current members: #{usage[:members]}"
    assert_includes body, "Discussions: #{usage[:discussions]}"
    assert_includes body, "Polls: #{usage[:polls]}"
    assert_includes body, "Comments: #{usage[:comments]}"
    assert_includes body, "permanently deleted"
    refute_includes body, "https://help.loomio.org/en/user_manual/groups/data_export/"
  end

  test "requested deletion warning identifies the requestor" do
    group = groups(:group)
    requestor = users(:admin)

    email = GroupMailer.admin_deletion_warning(group.id, requestor.id, requestor.id)

    AppConfig.stub(:discarded_group_deletion_after_days, 90) do
      assert_includes email.body.decoded, "scheduled for deletion by #{requestor.name}"
      assert_includes email.body.decoded, "Reply to this email immediately"
      assert_includes email.body.decoded, "once it has been unavailable for 90 days"
    end
  end

  test "catch-up warning describes old trial cleanup and includes the reply window" do
    group = groups(:trial_cleanup_poll)
    recipient = users(:admin)

    email = GroupMailer.expired_trial_deletion_warning(group.id, recipient.id, catch_up: true)
    body = AppConfig.stub(:discarded_group_deletion_after_days, 90) { email.body.decoded }

    assert_includes body, "A Loomio trial was created for “#{group.name}” some time ago."
    assert_includes body, "cleaning up old trial data"
    assert_includes body, "Reply to this email immediately"
    refute_includes body, "trial expired 60 days ago"
  end

  test "cancellation notice uses the group discard and current admin" do
    group = groups(:group)
    admin = users(:admin)
    group.discard!
    discarded_at = group.discarded_at.iso8601(6)
    email = GroupMailer.canceled_subscription_deletion_warning(group.id, admin.id, discarded_at)
    body = AppConfig.stub(:discarded_group_deletion_after_days, 90) { email.body.decoded }

    assert_includes body, "subscription for “#{group.name}” was cancelled"
    assert_includes body, "Reply to this email immediately"
    assert_includes body, "may be permanently deleted once it has been unavailable for 90 days"
    assert_nil GroupMailer.canceled_subscription_deletion_warning(group.id, users(:user).id, discarded_at).to

    group.undiscard!
    assert_nil GroupMailer.canceled_subscription_deletion_warning(group.id, admin.id, discarded_at).to
  end

  test "all group notices describe the actual outcome when scheduled deletion is off" do
    group = groups(:group)
    trial = groups(:trial_cleanup_poll)
    admin = users(:admin)
    group.discard!

    notices = {
      GroupMailer.admin_deletion_warning(group.id, admin.id, admin.id) => "#{admin.name} made your Loomio group",
      GroupMailer.expired_trial_deletion_warning(trial.id, admin.id) => "expired 60 days ago",
      GroupMailer.expired_trial_deletion_warning(trial.id, admin.id, catch_up: true) => "cleaning up old trials",
      GroupMailer.canceled_subscription_deletion_warning(group.id, admin.id, group.discarded_at.iso8601(6)) => "was cancelled"
    }

    AppConfig.stub(:discarded_group_deletion_after_days, nil) do
      notices.each do |email, reason|
        assert_equal "Your Loomio group is unavailable", email.subject
        assert_includes email.body.decoded, reason
        assert_includes email.body.decoded, "scheduled deletion is currently disabled"
        assert_includes email.body.decoded, "request restored access or a copy"
        refute_includes email.body.decoded, "permanently deleted"
      end
    end
  end
end
