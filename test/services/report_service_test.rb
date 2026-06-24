require 'test_helper'

class ReportServiceTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @member = users(:member)
    @user = users(:user)
    @group = groups(:group)
  end

  test "counts tagged threads participated in per user" do
    authored_by_admin = DiscussionService.create(
      params: {title: "Tagged #{SecureRandom.hex(4)}", group_id: @group.id, tags: ['alpha']},
      actor: @admin
    )
    authored_by_user = DiscussionService.create(
      params: {title: "Tagged #{SecureRandom.hex(4)}", group_id: @group.id, tags: ['alpha', 'beta']},
      actor: @user
    )
    CommentService.create(comment: Comment.new(body: "I participated", parent: authored_by_admin), actor: @member)
    CommentService.create(comment: Comment.new(body: "Again", parent: authored_by_admin), actor: @member)
    Reaction.create!(reactable: authored_by_user, user: @member, reaction: '+1')

    report = ReportService.new(
      interval: 'month',
      group_ids: [@group.id],
      start_at: 1.day.ago,
      end_at: 1.day.from_now
    )

    assert_equal 1, report.tag_threads_per_user['alpha'][@admin.id]
    assert_equal 1, report.tag_threads_per_user['alpha'][@member.id]
    assert_equal 1, report.tag_threads_per_user['alpha'][@user.id]
    assert_equal 1, report.tag_threads_per_user['beta'][@user.id]
    assert_nil report.tag_threads_per_user['beta'][@member.id]

    assert_equal 1, report.tag_threads_authored_per_user['alpha'][@admin.id]
    assert_equal 1, report.tag_threads_authored_per_user['alpha'][@user.id]
    assert_equal 1, report.tag_threads_authored_per_user['beta'][@user.id]
    assert_nil report.tag_threads_authored_per_user['alpha'][@member.id]
  end
end
