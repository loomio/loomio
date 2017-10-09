module Dev::DiscussionsHelper
  include Dev::PollsHelper

  def create_discussion_with_nested_comments
    group = create_group_with_members
    group.reload

    EventParentMigrator.migrate_group!(group)

    discussion    = saved fake_discussion(group: group)
    DiscussionService.create(discussion: discussion, actor: group.admins.first)

    15.times do
      parent_author = fake_user
      group.add_member! parent_author
      parent = fake_comment(discussion: discussion)
      CommentService.create(comment: parent, actor: parent_author)

      (0..3).to_a.sample.times do
        reply_author = fake_user
        group.add_member! reply_author
        reply = fake_comment(discussion: discussion, parent: parent)
        CommentService.create(comment: reply, actor: reply_author)
      end
    end

    discussion.reload
  end
end
