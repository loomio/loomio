require 'test_helper'

class GroupExportServiceTest < ActiveSupport::TestCase
  def create_scenario
    admin = User.create!(email: "exportadmin#{SecureRandom.hex(4)}@example.com", name: 'admin', password: 'password', email_verified: true)
    member = User.create!(email: "exportmember#{SecureRandom.hex(4)}@example.com", name: 'member', password: 'password')
    alien = User.create!(email: "exportother#{SecureRandom.hex(4)}@example.com", name: 'alien', password: 'password')

    group = Group.create!(name: "exportgroup#{SecureRandom.hex(4)}", creator_id: admin.id)
    subgroup = Group.create!(name: "exportsubgroup#{SecureRandom.hex(4)}", creator_id: admin.id, parent_id: group.id)
    another_group = Group.create!(name: "exportanothergroup#{SecureRandom.hex(4)}", creator_id: alien.id)

    group.add_admin!(admin)
    group.add_member!(member)
    subgroup.add_admin!(admin)
    subgroup.add_member!(member)
    another_group.add_admin!(alien)

    discussion_template = DiscussionTemplate.create!(title: 'discussion_template', group: group, process_name: 'process_name', process_subtitle: 'process_subtitle', author: admin)
    poll_template = PollTemplate.create!(title: 'poll_template', group: group, process_name: 'process_name', process_subtitle: 'process_subtitle', poll_type: 'proposal', author: admin)

    tag = Tag.create!(name: "exptag#{SecureRandom.hex(4)}", group: group, color: '#abcdef')

    discussion = DiscussionService.create(params: { title: "export_discussion#{SecureRandom.hex(4)}", group_id: group.id, discussion_template_id: discussion_template.id, tags: [tag.name] }, actor: admin)
    sub_discussion = DiscussionService.create(params: { title: "export_sub_discussion#{SecureRandom.hex(4)}", group_id: subgroup.id }, actor: admin)

    comment = Comment.new(parent: discussion, body: 'export_comment')
    CommentService.create(comment: comment, actor: admin)
    sub_comment = Comment.new(parent: sub_discussion, body: 'export_sub_comment')
    CommentService.create(comment: sub_comment, actor: admin)

    poll = PollService.create(params: { title: "export_poll#{SecureRandom.hex(4)}", group_id: group.id, poll_type: 'proposal', closing_at: 1.day.from_now, poll_option_names: %w[Agree Disagree], poll_template_id: poll_template.id }, actor: admin)
    sub_poll = PollService.create(params: { title: "export_sub_poll#{SecureRandom.hex(4)}", group_id: subgroup.id, poll_type: 'proposal', closing_at: 1.day.from_now, poll_option_names: %w[Agree Disagree] }, actor: admin)

    # PollService.create already created poll options and stances for group members
    # Cast stances for the main poll
    admin_stance = poll.stances.find_by(participant_id: admin.id, latest: true)
    admin_stance.update!(choice: 'Agree', cast_at: Time.current)
    member_stance = poll.stances.find_by(participant_id: member.id, latest: true)
    member_stance.update!(choice: 'Disagree', cast_at: Time.current)

    poll.update_counts!
    sub_poll.update_counts!

    PollService.close(poll: poll, actor: admin)
    PollService.close(poll: sub_poll, actor: admin)

    # Services already created events and topic readers
    discussion_event = discussion.created_event

    Reaction.create!(reactable: discussion, user: member)
    Reaction.create!(reactable: poll, user: member)
    Reaction.create!(reactable: comment, user: member)

    {
      admin: admin, member: member, alien: alien,
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
    alien_id = data[:alien].id

    # Clean up in reverse dependency order
    # Polls and discussions are now found via topics.group_id
    group_poll_ids = Poll.joins(:topic).where(topics: { group_id: group_ids }).pluck(:id)
    group_discussion_ids = Discussion.joins(:topic).where(topics: { group_id: group_ids }).pluck(:id)

    group_topic_ids = Topic.where(group_id: group_ids).pluck(:id)
    comment_ids = Event.where(topic_id: group_topic_ids, eventable_type: 'Comment').pluck(:eventable_id)

    StanceReceipt.where(poll_id: group_poll_ids).delete_all
    Reaction.where(user_id: [admin_id, member_id]).delete_all
    Notification.where(user_id: [admin_id, member_id]).delete_all
    Event.where(topic_id: group_topic_ids).delete_all
    TopicReader.where(topic_id: group_topic_ids).delete_all
    StanceChoice.where(stance: Stance.where(poll_id: group_poll_ids)).delete_all
    Stance.where(poll_id: group_poll_ids).delete_all
    PollOption.where(poll_id: group_poll_ids).delete_all
    Outcome.where(poll_id: group_poll_ids).delete_all
    Poll.where(id: group_poll_ids).delete_all
    Comment.where(id: comment_ids).delete_all
    Topic.where(id: group_topic_ids).delete_all
    Discussion.where(id: group_discussion_ids).delete_all
    DiscussionTemplate.where(group_id: group_ids).delete_all
    PollTemplate.where(group_id: group_ids).delete_all
    Tag.where(group_id: group_ids).delete_all
    Membership.where(group_id: group_ids).delete_all
    Membership.where(group_id: data[:another_group].id).delete_all
    Group.where(id: data[:another_group].id).delete_all
    Group.where(id: group_ids).delete_all
    Identity.where(user_id: [admin_id, member_id, alien_id]).delete_all
    User.where(id: [admin_id, member_id, alien_id]).delete_all

    GroupExportService.import(filename)

    # Verify import recreated the data
    imported_admin = User.find_by!(email: admin.email)
    imported_member = User.find_by!(email: member.email)
    assert_nil User.find_by(email: data[:alien].email), "alien should not be imported"

    imported_group = Group.find_by!(name: group.name)
    imported_subgroup = Group.find_by!(name: data[:subgroup].name)
    assert_nil Group.find_by(name: data[:another_group].name), "another_group should not be imported"

    # Memberships
    assert Membership.find_by(user: imported_admin, group: imported_group, admin: true)
    assert Membership.find_by(user: imported_admin, group: imported_subgroup, admin: true)
    assert Membership.find_by(user: imported_member, group: imported_group, admin: false)
    assert Membership.find_by(user: imported_member, group: imported_subgroup, admin: false)

    # Discussions (group_id is on topics, not discussions)
    imported_discussion = imported_group.discussions.find_by!(title: data[:discussion].title, author: imported_admin)
    imported_subgroup.discussions.find_by!(title: data[:sub_discussion].title, author: imported_admin)

    assert_equal 1, imported_discussion.tags.count
    assert_equal data[:tag].name, imported_discussion.tags.first

    Tag.find_by!(name: data[:tag].name, group: imported_group, color: '#abcdef')

    # Comments
    imported_comment = imported_discussion.comments.find_by!(user: imported_admin, body: 'export_comment')

    # Polls and stances (group_id is on topics, not polls)
    imported_poll = imported_group.polls.find_by!(title: data[:poll].title, author: imported_admin)
    imported_sub_poll = imported_subgroup.polls.find_by!(title: data[:sub_poll].title, author: imported_admin)

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
