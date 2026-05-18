require 'test_helper'

class Api::V1::AnnouncementsControllerTest < ActionController::TestCase
  setup do
    @user = users(:discussion_author)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    sign_in @user
  end

  # Count tests
  test "count returns a count of recipients" do
    bill = User.create!(name: 'bill', email: 'bill@example.com', username: 'bill1234')
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    @group.add_member!(member)
    @group.add_member!(@user)

    discussion = discussions(:test_discussion)

    get :count, params: {
      recipient_emails_cmr: ['bill@example.com', 'new@example.com'].join(','),
      recipient_user_xids: [bill.id].join('x'),
      recipient_audience: 'group',
      discussion_id: discussion.id
    }

    assert_response :success
    json = JSON.parse(response.body)
    assert json['count'] > 0
  end

  # History tests
  test "history responds with event history" do
    sign_in @user
    @group.add_admin!(@user) unless @group.members.include?(@user)

    get :history, params: { group_id: @group.id }
    assert_response :success
  end

  # Announce > Poll > Group member & poll author tests
  test "poll create can add group members when members_can_add_guests=false" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    @group.add_member!(member)

    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      specified_voters_only: true,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    @group.update(members_can_add_guests: false)

    # Set user as non-admin member
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_user_ids: [member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal member.id, json['stances'][0]['participant_id']
  end

  test "poll create cannot invite guests when members_can_add_guests=false" do
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      specified_voters_only: true,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    @group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_emails: ['jim@example.com'] }
    assert_response :forbidden
  end

  test "poll create can invite guests when members_can_add_guests=true" do
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      specified_voters_only: true,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    @group.update(members_can_add_guests: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_emails: ['jim@example.com'] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['stances'].length
  end

  test "poll create member cannot announce when members_can_announce=false" do
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      specified_voters_only: true,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_audience: 'group' }
    assert_response :forbidden
  end

  test "poll create member can notify voters when members_can_announce=false" do
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      specified_voters_only: true,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_audience: 'voters' }
    assert_response :success
  end

  test "poll create member can announce when members_can_announce=true" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    @group.add_member!(member)

    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      specified_voters_only: true,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    @group.update(members_can_announce: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_audience: 'group', recipient_user_ids: [@user.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @group.members.count, json['stances'].length
  end

  test "poll create as admin can add group member" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    @group.add_member!(member)

    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      specified_voters_only: true,
      poll_option_names: ["Yes", "No"],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: true)

    post :create, params: { poll_id: poll.id, recipient_user_ids: [member.id], notify_recipients: true }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['stances'].length
    assert_equal member.id, json['stances'][0]['participant_id']
    assert_equal 1, member.reload.notifications.count
    assert_includes poll.voters, member
  end

  test "poll create as admin can add group member with notification" do
    member = User.create!(name: 'invited_member', email: 'invited@example.com', username: 'invitedmember1234')
    @group.add_member!(member)

    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      specified_voters_only: true,
      poll_option_names: ["Yes", "No"],
      closing_at: 5.days.from_now
    )
    PollService.create(poll: poll, actor: @user)

    @group.update(members_can_announce: false, members_can_add_guests: false)

    post :create, params: { poll_id: poll.id, recipient_user_ids: [member.id], notify_recipients: true }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['stances'].length
    assert_equal 1, member.notifications.count
  end

  # Discussion announcement tests
  test "discussion create members can add guests when permission enabled" do
    discussion = discussions(:test_discussion)

    discussion.group.update(members_can_add_guests: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { discussion_id: discussion.id, recipient_emails: ['jim@example.com'] }
    assert_response :success
  end

  test "discussion create members cannot add guests when permission disabled" do
    discussion = discussions(:test_discussion)

    discussion.group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { discussion_id: discussion.id, recipient_emails: ['jim@example.com'] }
    assert_response :forbidden
  end

  test "discussion create members can announce when permission enabled" do
    discussion = discussions(:test_discussion)

    discussion.group.update(members_can_announce: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { discussion_id: discussion.id, recipient_audience: 'group' }
    assert_response :success
  end

  test "discussion create members cannot announce when permission disabled" do
    discussion = discussions(:test_discussion)

    discussion.group.update(members_can_announce: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { discussion_id: discussion.id, recipient_audience: 'group' }
    assert_response :forbidden
  end

  test "discussion create as admin can add member" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    @group.add_member!(member)

    discussion = discussions(:test_discussion)

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: true)

    post :create, params: { discussion_id: discussion.id, recipient_user_ids: [member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal member.id, json['discussion_readers'][0]['user_id']
    assert_equal 1, member.notifications.count
    assert_includes discussion.readers, member
  end

  test "discussion create as admin cannot add non_member" do
    non_member = User.create!(name: 'non_member', email: 'non@example.com', username: 'nonmember1234')

    discussion = discussions(:test_discussion)

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: true)

    post :create, params: { discussion_id: discussion.id, recipient_user_ids: [non_member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 0, json['discussion_readers'].length
  end

  test "discussion create as admin can add multiple members" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    @group.add_member!(member)

    discussion = discussions(:test_discussion)

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: true)

    post :create, params: { discussion_id: discussion.id, recipient_user_ids: [member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal member.id, json['discussion_readers'][0]['user_id']
    assert_equal 1, member.notifications.count
    assert_includes discussion.readers, member
  end

  # Outcome announcement tests
  test "outcome create does not permit stranger to announce" do
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      closed_at: 1.day.ago,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    outcome = Outcome.new(poll: poll, author: @user, statement: "Test outcome")
    OutcomeService.create(outcome: outcome, actor: @user)

    stranger = User.create!(name: 'stranger', email: 'stranger@example.com', username: 'stranger1234')
    sign_in stranger

    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')

    post :create, params: { outcome_id: outcome.id, recipient_user_ids: [member.id] }
    assert_response :forbidden
  end

  test "outcome create member can add members when permission enabled" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    @group.add_member!(member)

    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      closed_at: 1.day.ago,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    outcome = Outcome.new(poll: poll, author: @user, statement: "Test outcome")
    OutcomeService.create(outcome: outcome, actor: @user)

    @group.update(members_can_add_guests: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    member.notifications.destroy_all

    post :create, params: { outcome_id: outcome.id, recipient_user_ids: [member.id] }
    assert_response :success

    assert_equal 1, member.notifications.count
  end

  test "outcome create member cannot add guests when permission disabled" do
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      closed_at: 1.day.ago,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    outcome = Outcome.new(poll: poll, author: @user, statement: "Test outcome")
    OutcomeService.create(outcome: outcome, actor: @user)

    @group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { outcome_id: outcome.id, recipient_emails: ['jim@example.com'] }
    assert_response :forbidden
  end

  test "outcome create member can notify group when permission enabled" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    @group.add_member!(member)

    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      closed_at: 1.day.ago,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    outcome = Outcome.new(poll: poll, author: @user, statement: "Test outcome")
    OutcomeService.create(outcome: outcome, actor: @user)

    @group.update(members_can_announce: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { outcome_id: outcome.id, recipient_audience: 'group' }
    assert_response :success
  end

  test "outcome create member cannot notify group when permission disabled" do
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      closed_at: 1.day.ago,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    outcome = Outcome.new(poll: poll, author: @user, statement: "Test outcome")
    OutcomeService.create(outcome: outcome, actor: @user)

    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { outcome_id: outcome.id, recipient_audience: 'group' }
    assert_response :forbidden
  end

  test "outcome create with member notification" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    @group.add_member!(member)

    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      group: @group,
      author: @user,
      closed_at: 1.day.ago,
      poll_option_names: ["Yes", "No"]
    )
    PollService.create(poll: poll, actor: @user)

    outcome = Outcome.new(poll: poll, author: @user, statement: "Test outcome")
    OutcomeService.create(outcome: outcome, actor: @user)

    post :create, params: { outcome_id: outcome.id, recipient_user_ids: [member.id] }
    assert_response :success
  end

  # Group announcement tests
  test "group create allows adding members when permission enabled" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')

    @group.add_member!(member, inviter: @user)
    @group.update(members_can_add_members: true)

    sign_in member

    post :create, params: { group_id: @group.id, recipient_emails: ['jim@example.com'] }
    assert_response :success
  end

  test "group create disallows adding members when permission disabled" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')

    @group.add_member!(member, inviter: @user)
    @group.update(members_can_add_members: false)

    sign_in member

    post :create, params: { group_id: @group.id, recipient_emails: ['jim@example.com'] }
    assert_response :forbidden
  end

  test "group create cannot add existing user by id if no groups in common" do
    another_user = User.create!(name: 'another', email: 'another@example.com', username: 'another1234')

    post :create, params: { group_id: @group.id, recipient_user_ids: [another_user.id] }
    assert_response :success

    assert_equal 0, another_user.notifications.count
    assert_equal 0, another_user.memberships.count
  end

  test "group create with existing member notification" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    @group.add_member!(member)

    post :create, params: { group_id: @group.id, recipient_user_ids: [member.id] }
    assert_response :success

    assert_equal 1, member.notifications.count
    assert_includes @group.members, member
  end

  test "group create invite with multiple groups" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    subgroup = Group.create!(name: "Test Subgroup", parent: @group, handle: "testgroup-subgroup")
    subgroup2 = Group.create!(name: "Test Subgroup 2", parent: @group, handle: "testgroup-subgroup2")

    @group.add_member!(member, inviter: @user)
    subgroup.add_admin!(@user)
    subgroup2.add_admin!(@user)

    post :create, params: {
      group_id: @group.id,
      recipient_user_ids: [member.id],
      invited_group_ids: [subgroup.id, subgroup2.id]
    }

    assert_response :success
    assert_includes @group.members, member
  end

  test "group create does not invite users with no group in common" do
    another_user = User.create!(name: 'another', email: 'another@example.com', username: 'another1234')

    post :create, params: {
      group_id: @group.id,
      recipient_user_ids: [another_user.id],
      invited_group_ids: [@group.id]
    }

    assert_response :success
    assert_equal 0, another_user.notifications.count
    assert_equal 0, another_user.memberships.pending.count
  end

  test "group create invites to subgroup" do
    member = User.create!(name: 'member', email: 'member@example.com', username: 'member1234')
    subgroup = Group.create!(name: "Test Subgroup", parent: @group, handle: "testgroup-subgroup")

    @group.add_member!(member)
    subgroup.add_admin!(@user)

    post :create, params: { group_id: subgroup.id, recipient_user_ids: [member.id] }

    assert_response :success
    member.reload

    assert_equal 1, member.notifications.count
  end
end
