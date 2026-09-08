require "test_helper"

class GroupMailerTest < ActionMailer::TestCase
  test "deletion warning includes usage and export instructions" do
    group = groups(:group)
    recipient = users(:admin)
    usage = GroupUsageSummary.for(group)

    email = GroupMailer.destroy_warning(group.id, recipient.id, nil, "trial_expired")
    body = email.body.decoded

    assert_equal "Your Loomio group is scheduled for deletion", email.subject
    assert_includes body, "expired trial for at least 60 days"
    assert_includes body, "Subgroups: #{usage[:subgroups]}"
    assert_includes body, "Current members: #{usage[:members]}"
    assert_includes body, "Discussions: #{usage[:discussions]}"
    assert_includes body, "Polls: #{usage[:polls]}"
    assert_includes body, "Comments: #{usage[:comments]}"
    assert_includes body, "reply to this email within 2 weeks"
    assert_includes body, "https://help.loomio.org/en/user_manual/groups/data_export/"
  end

  test "requested deletion warning identifies the requester" do
    group = groups(:group)
    requester = users(:admin)

    email = GroupMailer.destroy_warning(group.id, requester.id, requester.id)

    assert_includes email.body.decoded, "scheduled for deletion by #{requester.name}"
  end
end
