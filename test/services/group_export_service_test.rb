require 'test_helper'

class GroupExportServiceTest < ActiveSupport::TestCase
  def create_scenario
    admin = User.create!(email: "exportadmin#{SecureRandom.hex(4)}@example.com", name: 'admin', password: 'password')
    member = User.create!(email: "exportmember#{SecureRandom.hex(4)}@example.com", name: 'member', password: 'password')
    another_user = User.create!(email: "exportother#{SecureRandom.hex(4)}@example.com", name: 'another_user', password: 'password')

    group = Group.create!(name: "exportgroup#{SecureRandom.hex(4)}", creator_id: admin.id)
    subgroup = Group.create!(name: "exportsubgroup#{SecureRandom.hex(4)}", creator_id: admin.id, parent_id: group.id)
    another_group = Group.create!(name: "exportanothergroup#{SecureRandom.hex(4)}", creator_id: another_user.id)

    group.add_admin!(admin)
    group.add_member!(member)
    subgroup.add_admin!(admin)
    subgroup.add_member!(member)
    another_group.add_admin!(another_user)

    discussion_template = DiscussionTemplate.create!(title: 'discussion_template', group: group, process_name: 'process_name', process_subtitle: 'process_subtitle', author: admin)
    poll_template = PollTemplate.create!(title: 'poll_template', group: group, process_name: 'process_name', process_subtitle: 'process_subtitle', poll_type: 'proposal', author: admin)

    tag = Tag.create!(name: "exptag#{SecureRandom.hex(4)}", group: group, color: '#abcdef')

    discussion = Discussion.create!(title: "export_discussion#{SecureRandom.hex(4)}", group: group, author: admin, discussion_template_id: discussion_template.id, tags: [tag.name])
    sub_discussion = Discussion.create!(title: "export_sub_discussion#{SecureRandom.hex(4)}", group: subgroup, author: admin)

    comment = Comment.create!(body: 'export_comment', discussion: discussion, author: admin)
    sub_comment = Comment.create!(body: 'export_sub_comment', discussion: sub_discussion, author: admin)

    poll = Poll.create!(title: "export_poll#{SecureRandom.hex(4)}", group: group, author: admin, poll_type: 'proposal', closing_at: 1.day.from_now, opened_at: Time.now, poll_template_id: poll_template.id)
    sub_poll = Poll.create!(title: "export_sub_poll#{SecureRandom.hex(4)}", group: subgroup, author: admin, poll_type: 'proposal', closing_at: 1.day.from_now, opened_at: Time.now)

    PollOption.create!(poll: poll, name: 'agree')
    PollOption.create!(poll: poll, name: 'disagree')
    PollOption.create!(poll: sub_poll, name: 'agree')
    PollOption.create!(poll: sub_poll, name: 'disagree')

    Stance.create!(poll: poll, participant: admin, choice: 'agree')
    Stance.create!(poll: poll, participant: member, choice: 'disagree')
    Stance.create!(poll: sub_poll, participant: admin, choice: nil, cast_at: nil)
    Stance.create!(poll: sub_poll, participant: member, choice: nil, cast_at: nil)

    poll.update_counts!
    sub_poll.update_counts!

    PollService.close(poll: poll, actor: admin)
    PollService.close(poll: sub_poll, actor: admin)

    discussion_event = Event.create!(eventable: discussion, user: admin, kind: 'discussion_created')
    comment_event = Event.create!(discussion: discussion, eventable: comment, user: admin, kind: 'new_comment')

    DiscussionReader.create!(discussion: discussion, user: admin)

    notification = discussion_event.notifications.create!(user: member, actor: admin)

    Reaction.create!(reactable: discussion, user: member)
    Reaction.create!(reactable: poll, user: member)
    Reaction.create!(reactable: comment, user: member)

    {
      admin: admin, member: member, another_user: another_user,
      group: group, subgroup: subgroup, another_group: another_group,
      discussion: discussion, sub_discussion: sub_discussion,
      comment: comment, poll: poll, sub_poll: sub_poll,
      tag: tag, discussion_template: discussion_template, poll_template: poll_template
    }
  end

  test "export, truncate specific records, and import recreates the scenario" do
    data = create_scenario
    group = data[:group]
    admin = data[:admin]
    member = data[:member]

    filename = GroupExportService.export(group.all_groups, group.name)

    # Delete just the records we created (not all tables, to preserve fixtures)
    group_ids = group.all_groups.pluck(:id)
    admin_id = admin.id
    member_id = member.id
    another_user_id = data[:another_user].id

    # Clean up in reverse dependency order
    StanceReceipt.where(poll: Poll.where(group_id: group_ids)).delete_all
    Reaction.where(user_id: [admin_id, member_id]).delete_all
    Notification.where(user_id: [admin_id, member_id]).delete_all
    Event.where(discussion: Discussion.where(group_id: group_ids)).delete_all
    Event.where(eventable_type: 'Poll', eventable_id: Poll.where(group_id: group_ids).pluck(:id)).delete_all
    DiscussionReader.where(discussion: Discussion.where(group_id: group_ids)).delete_all
    StanceChoice.where(stance: Stance.where(poll: Poll.where(group_id: group_ids))).delete_all
    Stance.where(poll: Poll.where(group_id: group_ids)).delete_all
    PollOption.where(poll: Poll.where(group_id: group_ids)).delete_all
    Poll.where(group_id: group_ids).delete_all
    Comment.where(discussion: Discussion.where(group_id: group_ids)).delete_all
    Discussion.where(group_id: group_ids).delete_all
    DiscussionTemplate.where(group_id: group_ids).delete_all
    PollTemplate.where(group_id: group_ids).delete_all
    Tag.where(group_id: group_ids).delete_all
    Membership.where(group_id: group_ids).delete_all
    Membership.where(group_id: data[:another_group].id).delete_all
    Group.where(id: data[:another_group].id).delete_all
    Group.where(id: group_ids).delete_all
    Identity.where(user_id: [admin_id, member_id, another_user_id]).delete_all
    User.where(id: [admin_id, member_id, another_user_id]).delete_all

    GroupExportService.import(filename)

    # Verify import recreated the data
    imported_admin = User.find_by!(email: admin.email)
    imported_member = User.find_by!(email: member.email)
    assert_nil User.find_by(email: data[:another_user].email), "another_user should not be imported"

    imported_group = Group.find_by!(name: group.name)
    imported_subgroup = Group.find_by!(name: data[:subgroup].name)
    assert_nil Group.find_by(name: data[:another_group].name), "another_group should not be imported"

    # Memberships
    assert Membership.find_by(user: imported_admin, group: imported_group, admin: true)
    assert Membership.find_by(user: imported_admin, group: imported_subgroup, admin: true)
    assert Membership.find_by(user: imported_member, group: imported_group, admin: false)
    assert Membership.find_by(user: imported_member, group: imported_subgroup, admin: false)

    # Discussions
    imported_discussion = Discussion.find_by!(title: data[:discussion].title, group: imported_group, author: imported_admin)
    Discussion.find_by!(title: data[:sub_discussion].title, group: imported_subgroup, author: imported_admin)

    assert_equal 1, imported_discussion.tags.count
    assert_equal data[:tag].name, imported_discussion.tags.first

    Tag.find_by!(name: data[:tag].name, group: imported_group, color: '#abcdef')

    # Comments
    Comment.find_by!(discussion: imported_discussion, user: imported_admin, body: 'export_comment')

    # Polls and stances
    imported_poll = Poll.find_by!(title: data[:poll].title, group: imported_group, author: imported_admin)
    imported_sub_poll = Poll.find_by!(title: data[:sub_poll].title, group: imported_subgroup, author: imported_admin)

    imported_poll.update_counts!
    imported_sub_poll.update_counts!

    assert_equal [1, 1], imported_poll.stance_counts
    assert_equal [0, 0], imported_sub_poll.stance_counts

    # Templates
    DiscussionTemplate.find_by!(title: 'discussion_template', group: imported_group, author: imported_admin)
    PollTemplate.find_by!(title: 'poll_template', group: imported_group, author: imported_admin)

    # Reactions
    Reaction.find_by!(reactable: imported_discussion, user: imported_member)
    Reaction.find_by!(reactable: imported_poll, user: imported_member)
  end
end
