require "test_helper"

class GroupMailerTest < ActionMailer::TestCase
  test "deletion warning includes usage and recovery instructions" do
    group = groups(:trial_cleanup_poll)
    recipient = users(:admin)
    usage = GroupUsageSummary.for(group)

    email = GroupMailer.expired_trial_deletion_warning(group.id, recipient.id)
    body = AppConfig.stub(:group_deletion_delay_days, 45) { email.body.decoded }

    assert_equal "Your Loomio group is scheduled for deletion", email.subject
    assert_includes body, "trial expired 60 days ago"
    assert_includes body, "Unless you contact us, it will be deleted in 45 days"
    assert_includes body, "Your group is unavailable while it is marked for deletion"
    assert_includes body, "it is not too late to restart"
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

    assert_includes email.body.decoded, "scheduled for deletion by #{requestor.name}"
  end
end
