require "test_helper"

class GroupMailerTest < ActionMailer::TestCase
  test "deletion warning includes usage and export instructions" do
    group = groups(:group)
    recipient = users(:admin)
    usage = GroupUsageSummary.for(group)

    email = GroupMailer.destroy_warning(group.id, recipient.id, nil, "trial_expired")
    body = AppConfig.stub(:group_deletion_grace_days, 45) { email.body.decoded }

    assert_equal "Your Loomio group is scheduled for deletion", email.subject
    assert_includes body, "expired trial for at least 60 days"
    assert_includes body, "Subgroups: #{usage[:subgroups]}"
    assert_includes body, "Current members: #{usage[:members]}"
    assert_includes body, "Discussions: #{usage[:discussions]}"
    assert_includes body, "Polls: #{usage[:polls]}"
    assert_includes body, "Comments: #{usage[:comments]}"
    assert_includes body, "permanently deleted after 45 days"
    assert_includes body, "reply to this email within 45 days"
    assert_includes body, "https://help.loomio.org/en/user_manual/groups/data_export/"
  end

  test "requested deletion warning identifies the requestor" do
    group = groups(:group)
    requestor = users(:admin)

    email = GroupMailer.destroy_warning(group.id, requestor.id, requestor.id)

    assert_includes email.body.decoded, "scheduled for deletion by #{requestor.name}"
  end
end
