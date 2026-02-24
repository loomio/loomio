require 'test_helper'

class Api::V1::AnnouncementsControllerTest < ActionController::TestCase
  setup do
    @user = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
    @discussion = discussions(:discussion)
    sign_in @user
  end

  # Count tests
  test "count returns a count of recipients" do
    hex = SecureRandom.hex(4)
    bill = User.create!(name: "bill#{hex}", email: "bill#{hex}@example.com", username: "bill#{hex}")
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    get :count, params: {
      recipient_emails_cmr: ["bill#{hex}@example.com", "new#{hex}@example.com"].join(','),
      recipient_user_xids: [bill.id].join('x'),
      recipient_audience: 'group',
      discussion_id: @discussion.id
    }

    assert_response :success
    json = JSON.parse(response.body)
    assert json['count'] > 0
  end

  # History tests
  test "history responds with event history" do
    get :history, params: { group_id: @group.id }
    assert_response :success
  end

  # -- Poll announcement tests --

  def create_test_poll(**extra)
    PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      group_id: @group.id,
      specified_voters_only: true,
      poll_option_names: %w[agree disagree],
      closing_at: 5.days.from_now
    }.merge(extra), actor: @user)
  end

  test "poll create can add group members when members_can_add_guests=false" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)
    poll = create_test_poll

    @group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_user_ids: [member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal member.id, json['stances'][0]['participant_id']
  end

  test "poll create cannot invite guests when members_can_add_guests=false" do
    poll = create_test_poll

    @group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_emails: ['jim@example.com'] }
    assert_response :forbidden
  end

  test "poll create can invite guests when members_can_add_guests=true" do
    poll = create_test_poll

    @group.update(members_can_add_guests: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_emails: ['jim@example.com'] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['stances'].length
  end

  test "poll create member cannot announce when members_can_announce=false" do
    poll = create_test_poll

    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_audience: 'group' }
    assert_response :forbidden
  end

  test "poll create member can notify voters when members_can_announce=false" do
    poll = create_test_poll

    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_audience: 'voters' }
    assert_response :success
  end

  test "poll create member can announce when members_can_announce=true" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)
    poll = create_test_poll

    @group.update(members_can_announce: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { poll_id: poll.id, recipient_audience: 'group', recipient_user_ids: [@user.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @group.members.count, json['stances'].length
  end

  test "poll create as admin can add group member" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)
    poll = create_test_poll

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
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)
    poll = create_test_poll

    @group.update(members_can_announce: false, members_can_add_guests: false)

    post :create, params: { poll_id: poll.id, recipient_user_ids: [member.id], notify_recipients: true }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['stances'].length
    assert_equal 1, member.notifications.count
  end

  # -- Discussion announcement tests --

  test "discussion create members can add guests when permission enabled" do
    @group.update(members_can_add_guests: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { discussion_id: @discussion.id, recipient_emails: ['jim@example.com'] }
    assert_response :success
  end

  test "discussion create members cannot add guests when permission disabled" do
    @group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { discussion_id: @discussion.id, recipient_emails: ['jim@example.com'] }
    assert_response :forbidden
  end

  test "discussion create members can announce when permission enabled" do
    @group.update(members_can_announce: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { discussion_id: @discussion.id, recipient_audience: 'group' }
    assert_response :success
  end

  test "discussion create members cannot announce when permission disabled" do
    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { discussion_id: @discussion.id, recipient_audience: 'group' }
    assert_response :forbidden
  end

  test "discussion create as admin can add member" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: true)

    post :create, params: { discussion_id: @discussion.id, recipient_user_ids: [member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal member.id, json['topic_readers'][0]['user_id']
    assert_equal 1, member.notifications.count
    assert_includes @discussion.readers, member
  end

  test "discussion create as admin cannot add non_member" do
    hex = SecureRandom.hex(4)
    non_member = User.create!(name: "non#{hex}", email: "non#{hex}@example.com", username: "non#{hex}")

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: true)

    post :create, params: { discussion_id: @discussion.id, recipient_user_ids: [non_member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 0, json['topic_readers'].length
  end

  test "discussion create as admin can add multiple members" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    @group.update(members_can_announce: false, members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: true)

    post :create, params: { discussion_id: @discussion.id, recipient_user_ids: [member.id] }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal member.id, json['topic_readers'][0]['user_id']
    assert_equal 1, member.notifications.count
    assert_includes @discussion.readers, member
  end

  # -- Outcome announcement tests --

  def create_closed_poll_with_outcome
    poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      group_id: @group.id,
      poll_option_names: %w[agree disagree],
      closing_at: 3.days.from_now
    }, actor: @user)
    PollService.close(poll: poll, actor: @user)
    outcome = Outcome.new(poll: poll, author: @user, statement: "Test outcome")
    OutcomeService.create(outcome: outcome, actor: @user)
    [poll, outcome]
  end

  test "outcome create does not permit stranger to announce" do
    _poll, outcome = create_closed_poll_with_outcome

    hex = SecureRandom.hex(4)
    stranger = User.create!(name: "stranger#{hex}", email: "stranger#{hex}@example.com", username: "stranger#{hex}")
    sign_in stranger

    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")

    post :create, params: { outcome_id: outcome.id, recipient_user_ids: [member.id] }
    assert_response :forbidden
  end

  test "outcome create member can add members when permission enabled" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    _poll, outcome = create_closed_poll_with_outcome

    @group.update(members_can_add_guests: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    member.notifications.destroy_all

    post :create, params: { outcome_id: outcome.id, recipient_user_ids: [member.id] }
    assert_response :success

    assert_equal 1, member.notifications.count
  end

  test "outcome create member cannot add guests when permission disabled" do
    _poll, outcome = create_closed_poll_with_outcome

    @group.update(members_can_add_guests: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { outcome_id: outcome.id, recipient_emails: ['jim@example.com'] }
    assert_response :forbidden
  end

  test "outcome create member can notify group when permission enabled" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    _poll, outcome = create_closed_poll_with_outcome

    @group.update(members_can_announce: true)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { outcome_id: outcome.id, recipient_audience: 'group' }
    assert_response :success
  end

  test "outcome create member cannot notify group when permission disabled" do
    _poll, outcome = create_closed_poll_with_outcome

    @group.update(members_can_announce: false)
    Membership.find_by(user_id: @user.id, group_id: @group.id).update(admin: false)

    post :create, params: { outcome_id: outcome.id, recipient_audience: 'group' }
    assert_response :forbidden
  end

  test "outcome create with member notification" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    _poll, outcome = create_closed_poll_with_outcome

    post :create, params: { outcome_id: outcome.id, recipient_user_ids: [member.id] }
    assert_response :success
  end

  # -- Group announcement tests --

  test "group create allows adding members when permission enabled" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member, inviter: @user)
    @group.update(members_can_add_members: true)

    sign_in member

    post :create, params: { group_id: @group.id, recipient_emails: ["jim#{hex}@example.com"] }
    assert_response :success
  end

  test "group create disallows adding members when permission disabled" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member, inviter: @user)
    @group.update(members_can_add_members: false)

    sign_in member

    post :create, params: { group_id: @group.id, recipient_emails: ["jim#{hex}@example.com"] }
    assert_response :forbidden
  end

  test "group create cannot add existing user by id if no groups in common" do
    hex = SecureRandom.hex(4)
    alien = User.create!(name: "another#{hex}", email: "another#{hex}@example.com", username: "another#{hex}")

    post :create, params: { group_id: @group.id, recipient_user_ids: [alien.id] }
    assert_response :success

    assert_equal 0, alien.notifications.count
    assert_equal 0, alien.memberships.count
  end

  test "group create with existing member notification" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    @group.add_member!(member)

    post :create, params: { group_id: @group.id, recipient_user_ids: [member.id] }
    assert_response :success

    assert_equal 1, member.notifications.count
    assert_includes @group.members, member
  end

  test "group create invite with multiple groups" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    subgroup = Group.create!(name: "Test Sub #{hex}", parent: @group, handle: "testgroup-sub#{hex}")
    subgroup2 = Group.create!(name: "Test Sub2 #{hex}", parent: @group, handle: "testgroup-sub2#{hex}")

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
    hex = SecureRandom.hex(4)
    alien = User.create!(name: "another#{hex}", email: "another#{hex}@example.com", username: "another#{hex}")

    post :create, params: {
      group_id: @group.id,
      recipient_user_ids: [alien.id],
      invited_group_ids: [@group.id]
    }

    assert_response :success
    assert_equal 0, alien.notifications.count
    assert_equal 0, alien.memberships.pending.count
  end

  test "group create invites to subgroup" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}")
    subgroup = Group.create!(name: "Test Sub #{hex}", parent: @group, handle: "testgroup-sub#{hex}")

    @group.add_member!(member)
    subgroup.add_admin!(@user)
    subgroup.add_member!(member)

    post :create, params: { group_id: subgroup.id, recipient_user_ids: [member.id] }

    assert_response :success
    member.reload

    assert_equal 1, member.notifications.count
  end
end
