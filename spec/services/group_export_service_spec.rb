require 'rails_helper'

describe GroupExportService do
  def create_scenario
    admin = User.create!(email: 'admin@example.com', name: 'admin', password: 'password')
    member = User.create!(email: 'member@example.com', name: 'member', password: 'password')
    another_user = User.create!(email: 'another_user@example.com', name: 'another_user', password: 'password')

    group = Group.create!(name: 'group', creator_id: admin.id)
    subgroup = Group.create!(name: 'subgroup', creator_id: admin.id, parent_id: group.id)
    another_group = Group.create!(name: 'another_group', creator_id: another_user.id)

    group.add_admin!(admin)
    group.add_member!(member)
    subgroup.add_admin!(admin)
    subgroup.add_member!(member)
    another_group.add_admin!(another_user)

    discussion_template = DiscussionTemplate.create!(title: 'discussion_template', group: group, process_name: 'process_name', author: admin)
    poll_template = PollTemplate.create!(title: 'poll_template', group: group, process_name: 'process_name', process_subtitle: 'process_subtitle', poll_type: 'proposal', author: admin)

    tag = Tag.create!(name: 'tag', group: group, color: '#abcdef')

    discussion = Discussion.create!(title: 'discussion', group: group, author: admin, discussion_template_id: discussion_template.id, tags: ['tag'])
    sub_discussion = Discussion.create!(title: 'sub_discussion', group: subgroup, author: admin)

    comment = Comment.create!(body: 'comment', discussion: discussion, author: admin)
    sub_comment = Comment.create!(body: 'sub_comment', discussion: sub_discussion, author: admin)

    poll = Poll.create!(title: 'poll', group: group, author: admin, poll_type: 'proposal', closing_at: 1.day.from_now, poll_template_id: poll_template.id)
    sub_poll = Poll.create!(title: 'sub_poll', group: subgroup, author: admin, poll_type: 'proposal', closing_at: 1.day.from_now)

    poll_option_agree = PollOption.create!(poll: poll, name: 'agree')
    poll_option_disagree = PollOption.create!(poll: poll, name: 'disagree')
    poll_option_sub_agree = PollOption.create!(poll: sub_poll, name: 'agree')
    poll_option_sub_disagree = PollOption.create!(poll: sub_poll, name: 'disagree')

    Stance.create!(poll: poll, participant: admin, choice: 'agree')
    Stance.create!(poll: poll, participant: member, choice: 'disagree')
    Stance.create!(poll: sub_poll, participant: admin, choice: nil, cast_at: nil)
    Stance.create!(poll: sub_poll, participant: member, choice: nil, cast_at: nil)

    poll.update_counts!
    sub_poll.update_counts!

    PollService.close(poll: poll, actor: admin)
    PollService.close(poll: sub_poll, actor: admin)

    assert StanceReceipt.count == 4

    discussion_event = Event.create!(eventable: discussion, user: admin, kind: 'discussion_created')
    comment_event = Event.create!(discussion: discussion, eventable: comment, user: admin, kind: 'new_comment')

    discussion_reader = DiscussionReader.create!(discussion: discussion, user: admin)

    notification = discussion_event.notifications.create!(user: member, actor: admin)

    discussion_reaction = Reaction.create!(reactable: discussion, user: member)
    poll_reaction = Reaction.create!(reactable: poll, user: member)
    comment_reaction = Reaction.create!(reactable: comment, user: member)

    p('before', {
      admin_id: admin.id,
      member_id: member.id,
      group_id: group.id,
      subgroup_id: subgroup.id,
      discussion_id: discussion.id,
      comment_id: comment.id,
      poll_id: poll.id,
    })
  end

  def truncate_tables
    [StanceReceipt, Group, Membership, User, Discussion, DiscussionTemplate, Comment, Poll, PollTemplate, PollOption, Stance, StanceChoice,
     Reaction, Event, Notification, Document, DiscussionReader, Tag].each do |model|
       ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{model.table_name}")
    end
  end

  describe 'export, truncate, import' do
    before do
      create_scenario
      group = Group.find_by(name: 'group')
      filename = GroupExportService.export(group.all_groups, group.name)
      truncate_tables
      GroupExportService.import(filename)
    end

    it 'completely recreates the scenario' do
      admin = User.find_by!(email: 'admin@example.com')
      member = User.find_by!(email: 'member@example.com')
      assert User.where(email: 'another_user@example.com').none?

      group = Group.find_by!(name: 'group')
      subgroup = Group.find_by!(name: 'subgroup')
      assert Group.where(name: 'another_group').none?

      Membership.find_by!(user: admin, group: group, admin: true)
      Membership.find_by!(user: admin, group: subgroup, admin: true)

      Membership.find_by!(user: member, group: group, admin: false)
      Membership.find_by!(user: member, group: subgroup, admin: false)

      assert Membership.count == 4

      discussion = Discussion.find_by!(title: 'discussion', group: group, author: admin)
      sub_discussion = Discussion.find_by!(title: 'sub_discussion', group: subgroup, author: admin)

      assert discussion.tags.count == 1
      assert discussion.tags.first == 'tag'

      Tag.find_by!(name: 'tag', group: group, color: '#abcdef')

      comment = Comment.find_by!(discussion: discussion, user: admin, body: 'comment')
      sub_comment = Comment.find_by!(discussion: sub_discussion, user: admin, body: 'sub_comment')

      poll = Poll.find_by!(title: 'poll', group: group, author: admin)
      sub_poll = Poll.find_by!(title: 'sub_poll', group: subgroup, author: admin)

      poll.update_counts!
      sub_poll.update_counts!

      assert poll.stance_counts == [1, 1]
      assert sub_poll.stance_counts == [0, 0]

      assert Stance.count == 4
      Stance.find_by!(poll: poll, participant: admin)
      Stance.find_by!(poll: poll, participant: member)
      Stance.find_by!(poll: sub_poll, participant: admin)
      Stance.find_by!(poll: sub_poll, participant: member)

      assert StanceReceipt.count == 4
      StanceReceipt.find_by!(poll: poll, voter: admin, vote_cast: true)
      StanceReceipt.find_by!(poll: poll, voter: member, vote_cast: true)
      StanceReceipt.find_by!(poll: sub_poll, voter: admin, vote_cast: false)
      StanceReceipt.find_by!(poll: sub_poll, voter: member, vote_cast: false)

      discussion_template = DiscussionTemplate.find_by!(title: 'discussion_template', group: group, author: admin)
      poll_template = PollTemplate.find_by!(title: 'poll_template', group: group, author: admin)

      assert Reaction.count == 3
      Reaction.find_by!(reactable: discussion, user: member)
      Reaction.find_by!(reactable: poll, user: member)
      Reaction.find_by!(reactable: comment, user: member)
      # check reactions

    end

    # it "import on existing tables" do
    # end
  end
end
