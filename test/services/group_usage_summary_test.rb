require "test_helper"

class GroupUsageSummaryTest < ActiveSupport::TestCase
  test "counts exportable activity across the complete group tree" do
    admin = users(:admin)
    member = users(:member)
    group = Group.create!(name: "Usage summary root", group_privacy: "secret", creator: admin)
    group.add_admin!(admin)
    subgroup = Group.create!(name: "Usage summary child", group_privacy: "secret", creator: admin, parent: group)
    subgroup.add_member!(member)
    discussion = DiscussionService.create(params: { title: "Usage discussion", group_id: group.id }, actor: admin)
    CommentService.create(comment: Comment.new(parent: discussion, body: "Usage comment"), actor: admin)
    PollService.create(
      params: {
        title: "Usage poll", poll_type: "proposal", poll_option_names: %w[Yes No],
        closing_at: 1.day.from_now, topic_id: discussion.topic_id
      },
      actor: admin
    )

    assert_equal({ subgroups: 1, members: 2, discussions: 1, polls: 1, comments: 1 },
                 GroupUsageSummary.for(group))
  end
end
