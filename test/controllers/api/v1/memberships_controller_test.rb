require 'test_helper'

class Api::V1::MembershipsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @test_group = groups(:group)
    @subgroup = groups(:subgroup)
    sign_in @user
  end

  test "join group responds with the created membership" do
    group = Group.create!(
      name: "Open group #{SecureRandom.hex(4)}",
      group_privacy: "open",
      membership_granted_upon: "request"
    )
    sign_in @alien

    post :join_group, params: { group_id: group.id }

    assert_response :success
    membership = Membership.find_by!(group: group, user: @alien)
    assert_equal membership.id, JSON.parse(response.body).fetch("memberships").first.fetch("id")
  end

  # ===== Membership Creation Tests =====

  test 'sets the membership volume to user default' do
    new_group = Group.create!(
      name: 'New Group',
      handle: 'newgroup',
      is_visible_to_public: false
    )
    @user.update(default_membership_volume_email: 'quiet', default_membership_volume_push: 'normal')

    membership = Membership.create!(user: @user, group: new_group)

    assert_equal 'quiet', membership.volume_email
    assert_equal 'normal', membership.volume_push
  end

  # ===== Update Tests =====

  test 'updates membership title' do
    sign_in @admin
    member_user = User.create!(
      name: 'Member User',
      email: 'memberuser@example.com',
      email_verified: true,
      username: 'memberuser1'
    )
    @test_group.add_member!(member_user)
    m = @test_group.membership_for(member_user)

    post :update, params: { id: m.id, membership: { title: 'dr' } }

    assert_response :success
    assert_equal 'dr', m.reload.title
  end

  test 'user_name updates name but not username' do
    sign_in @admin
    member_user = User.create!(
      name: '',
      email: 'pendingmember@example.com',
      email_verified: false,
      username: 'pendingmember'
    )
    @test_group.add_member!(member_user)

    post :user_name, params: { id: member_user.id, name: 'Pending Member', username: 'claimedhandle' }

    assert_response :success
    assert_equal 'Pending Member', member_user.reload.name
    assert_equal 'pendingmember', member_user.username
  end

  # ===== Set Volume Tests =====

  test 'updates volume for single membership' do
    membership = @test_group.membership_for(@user)
    membership.set_volume!(email: 'quiet', push: 'quiet')

    second_membership = @subgroup.membership_for(@user)
    second_membership.set_volume!(email: 'quiet', push: 'quiet')

    put :set_volume, params: { id: membership.id, volume_email: 'loud', volume_push: 'normal' }

    membership.reload
    second_membership.reload

    assert_equal 'loud', membership.volume_email
    assert_equal 'normal', membership.volume_push
    assert_not_equal 'loud', second_membership.volume_email
  end

  test 'updates volume for all memberships when apply_to_all is true' do
    membership = @test_group.membership_for(@user)
    membership.set_volume!(email: 'quiet', push: 'quiet')

    second_membership = @subgroup.membership_for(@user)
    second_membership.set_volume!(email: 'quiet', push: 'quiet')

    put :set_volume, params: { id: membership.id, volume_email: 'loud', volume_push: 'normal', apply_to_all: true }

    membership.reload
    second_membership.reload

    assert_equal 'loud', membership.volume_email
    assert_equal 'normal', membership.volume_push
    assert_equal 'loud', second_membership.volume_email
    assert_equal 'normal', second_membership.volume_push
  end

  test 'rejects a missing volume without changing topic readers' do
    membership = @test_group.membership_for(@user)
    membership.set_volume!(email: 'quiet', push: 'quiet')
    topic_reader = TopicReader.for(user: @user, topic: topics(:discussion_topic))
    topic_reader.set_volume!(email: 'quiet', push: 'quiet')

    put :set_volume, params: { id: membership.id }

    assert_response :unprocessable_entity
    assert_equal ['is not a valid value'], response.parsed_body.dig('errors', 'volume_email')
    assert_equal 'quiet', membership.reload.volume_email
    assert_equal 'quiet', topic_reader.reload.volume_email
  end

  test 'group admins cannot change another members volumes' do
    membership = @test_group.membership_for(@user)
    sign_in @admin

    put :set_volume, params: { id: membership.id, volume_email: 'loud', volume_push: 'loud' }

    assert_response :forbidden
    assert_not_equal 'loud', membership.reload.volume_push
  end

  # ===== Index Tests =====

  test 'returns users filtered by group' do
    user1 = User.create!(
      name: 'User One',
      email: 'user1@example.com',
      email_verified: true,
      username: 'user1test'
    )
    user2 = User.create!(
      name: 'User Two',
      email: 'user2@example.com',
      email_verified: true,
      username: 'user2test'
    )
    @test_group.add_member!(user1)
    @test_group.add_member!(user2)

    get :index, params: { group_id: @test_group.id }, format: :json

    json = JSON.parse(response.body)
    assert_response :success
    assert_includes json.keys, 'users'
    assert_includes json.keys, 'memberships'
    assert_includes json.keys, 'groups'

    user_ids = json['users'].map { |u| u['id'] }
    group_ids = json['groups'].map { |g| g['id'] }

    assert_includes user_ids, user1.id
    assert_includes user_ids, user2.id
    assert_includes group_ids, @test_group.id

    own_membership = json['memberships'].find { |membership| membership['user_id'] == @user.id }
    other_membership = json['memberships'].find { |membership| membership['user_id'] == user1.id }
    assert own_membership.key?('volume_email')
    assert own_membership.key?('volume_push')
    refute other_membership.key?('volume_email')
    refute other_membership.key?('volume_push')
  end

  test 'search matches membership titles' do
    titled_user = User.create!(
      name: 'Plain Name',
      email: 'plain-name@example.com',
      email_verified: true,
      username: 'plainname'
    )
    untitled_user = User.create!(
      name: 'Other Person',
      email: 'other-person@example.com',
      email_verified: true,
      username: 'otherperson'
    )
    titled_membership = @test_group.add_member!(titled_user)
    @test_group.add_member!(untitled_user)
    titled_membership.update!(title: 'Working group facilitator')

    get :index, params: { group_id: @test_group.id, q: 'FACIL' }, format: :json

    json = JSON.parse(response.body)
    user_ids = json['users'].map { |u| u['id'] }

    assert_response :success
    assert_includes user_ids, titled_user.id
    refute_includes user_ids, untitled_user.id
  end

  test 'search does not match membership titles from another group' do
    other_group = Group.create!(
      name: 'Other Group',
      handle: 'other-title-group',
      is_visible_to_public: false
    )
    user = User.create!(
      name: 'Plain Other Title',
      email: 'plain-other-title@example.com',
      email_verified: true,
      username: 'plainothertitle'
    )
    @test_group.add_member!(user)
    other_membership = other_group.add_member!(user)
    other_membership.update!(title: 'External facilitator')

    get :index, params: { group_id: @test_group.id, q: 'facilitator' }, format: :json

    assert_response :success

    json = JSON.parse(response.body)
    user_ids = json.fetch('users', []).map { |u| u['id'] }

    refute_includes user_ids, user.id
  end

  test 'poll admin scope does not expose email addresses from other groups' do
    @test_group.membership_for(@user).update!(admin: true)
    source_poll = PollService.create(params: {
      title: "Membership scope source",
      poll_type: "proposal",
      group_id: @test_group.id,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 1.day.from_now
    }, actor: @user)

    hex = SecureRandom.hex(4)
    owner = User.create!(
      name: "Membership scope owner",
      email: "membership-scope-owner-#{hex}@example.com",
      email_verified: true,
      username: "membershipscopeowner#{hex}"
    )
    victim = User.create!(
      name: "Membership scope victim",
      email: "membership-scope-victim-#{hex}@example.com",
      email_verified: true,
      username: "membershipscopevictim#{hex}"
    )
    target_group = Group.create!(
      name: "Membership target group",
      handle: "membership-target-scope-#{hex}",
      group_privacy: "secret",
      creator: owner
    )
    Membership.create!(group: target_group, user: owner, admin: true, accepted_at: Time.current)
    Membership.create!(group: target_group, user: @user, admin: false, accepted_at: Time.current)
    victim_membership = Membership.create!(
      group: target_group,
      user: victim,
      admin: false,
      accepted_at: Time.current
    )
    @user.reload

    sign_in @user
    get :index, params: {poll_id: source_poll.id, per: 2000}

    assert_response :success
    json = JSON.parse(response.body)
    serialized_membership = json.fetch('memberships').find { |membership| membership['id'] == victim_membership.id }
    assert_not_nil serialized_membership
    assert_not serialized_membership.key?('user_email')
    serialized_user = json.fetch('users').find { |user| user['id'] == victim.id }
    assert_not serialized_user.key?('email')
  end

  test 'parent administrators cannot list memberships of hidden subgroups' do
    @test_group.membership_for(@user).update!(admin: true)
    hidden_subgroup = Group.create!(
      name: 'Hidden membership subgroup',
      handle: "#{@test_group.handle}-hidden-membership-subgroup-#{SecureRandom.hex(4)}",
      parent: @test_group,
      group_privacy: 'secret',
      is_visible_to_parent_members: false
    )
    hidden_member = User.create!(
      name: 'Hidden subgroup member',
      email: "hidden-subgroup-member-#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      username: "hiddensubgroupmember#{SecureRandom.hex(4)}"
    )
    hidden_membership = Membership.create!(group: hidden_subgroup, user: hidden_member, accepted_at: Time.current)
    @user.reload

    get :index, params: {group_id: @test_group.id, subgroups: 'all', per: 2000}

    assert_response :success
    membership_ids = JSON.parse(response.body).fetch('memberships').map { |membership| membership['id'] }
    refute_includes membership_ids, hidden_membership.id
  end

  test 'responds with unauthorized for private groups when logged out' do
    private_group = Group.create!(
      name: 'Private Group',
      handle: 'privategroup',
      is_visible_to_public: false
    )

    sign_out @user

    get :index, params: { group_id: private_group.id }, format: :json

    assert_response 403
  end

  test 'does not allow access to unauthorized group' do
    cant_see_me = Group.create!(
      name: 'Unauthorized Group',
      handle: 'unauthorizedgroup',
      is_visible_to_public: false
    )

    get :index, params: { group_id: cant_see_me.id }, format: :json

    assert_response 403
  end

  # ===== For User Tests =====

  test 'returns visible groups for the given user' do
    alien_group = groups(:alien_group)
    alien_group.update!(listed_in_explore: true)

    get :for_user, params: { user_id: @alien.id }

    json = JSON.parse(response.body)
    group_ids = json['groups'].map { |g| g['id'] }

    assert_includes group_ids, alien_group.id
  end

  # ===== Save Experience Tests =====

  test 'successfully saves an experience' do
    experience_user = User.create!(
      name: 'Experience User',
      email: 'expuser@example.com',
      email_verified: true,
      username: 'expuser1'
    )
    membership = Membership.create!(user: experience_user, group: @test_group, accepted_at: 1.day.ago)

    sign_in experience_user

    post :save_experience, params: { id: membership.id, experience: :happiness }

    assert_response :success
    assert_equal true, membership.reload.experiences['happiness']
  end

  test 'responds with forbidden when user is logged out for save_experience' do
    experience_user = User.create!(
      name: 'Experience User',
      email: 'expuser2@example.com',
      email_verified: true,
      username: 'expuser2'
    )
    membership = Membership.create!(user: experience_user, group: @test_group, accepted_at: 1.day.ago)

    sign_out @user

    post :save_experience, params: { id: membership.id, experience: :happiness }

    assert_response 403
  end

  # ===== Delegate Tests =====

  test 'make_delegate updates the membership record' do
    sign_in @admin
    delegate_user = User.create!(
      name: 'Delegate User',
      email: 'delegateuser@example.com',
      email_verified: true,
      username: 'delegateuser1'
    )
    membership = @test_group.add_member!(delegate_user)

    assert_equal false, membership.delegate

    post :make_delegate, params: { id: membership.id }

    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal true, response_json['memberships'][0]['delegate']

    membership.reload
    assert_equal true, membership.delegate
  end

  test 'make_delegate only works for group admins' do
    delegate_user = User.create!(
      name: 'Delegate User',
      email: 'delegateuser2@example.com',
      email_verified: true,
      username: 'delegateuser2'
    )
    @test_group.add_member!(delegate_user)

    sign_in @alien
    membership = @test_group.add_member!(delegate_user)

    post :make_delegate, params: { id: membership.id }

    assert_response 403
    assert_equal false, membership.reload.delegate
  end

  test 'remove_delegate updates the membership record' do
    sign_in @admin
    delegate_user = User.create!(
      name: 'Delegate User',
      email: 'delegateuser3@example.com',
      email_verified: true,
      username: 'delegateuser3'
    )
    membership = @test_group.add_member!(delegate_user)
    membership.update(delegate: true)

    assert_equal true, membership.delegate

    post :remove_delegate, params: { id: membership.id }

    assert_response :success
    response_json = JSON.parse(response.body)
    assert_equal false, response_json['memberships'][0]['delegate']

    membership.reload
    assert_equal false, membership.delegate
  end

  test 'remove_delegate only works for group admins' do
    delegate_user = User.create!(
      name: 'Delegate User',
      email: 'delegateuser4@example.com',
      email_verified: true,
      username: 'delegateuser4'
    )
    membership = @test_group.add_member!(delegate_user)
    membership.update(delegate: true)

    sign_in @alien

    post :remove_delegate, params: { id: membership.id }

    assert_response 403
    assert_equal true, membership.reload.delegate
  end
end
