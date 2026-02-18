require 'test_helper'

class Api::V1::MembershipsControllerTest < ActionController::TestCase
  setup do
    @normal_user = users(:normal_user)
    @another_user = users(:another_user)
    @test_group = groups(:test_group)
    @subgroup = groups(:subgroup)

    @test_group.add_admin!(@normal_user)
    @subgroup.add_admin!(@normal_user)
    sign_in @normal_user
  end

  # ===== Membership Creation Tests =====

  test 'sets the membership volume to user default' do
    new_group = Group.create!(
      name: 'New Group',
      handle: 'newgroup',
      is_visible_to_public: false
    )
    @normal_user.update(default_membership_volume: 'quiet')

    membership = Membership.create!(user: @normal_user, group: new_group)

    assert_equal 'quiet', membership.volume
  end

  # ===== Update Tests =====

  test 'updates membership title' do
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

  # ===== Set Volume Tests =====

  test 'updates volume for single membership' do
    @test_group.add_member!(@normal_user)
    @subgroup.add_member!(@normal_user)

    membership = @test_group.membership_for(@normal_user)
    membership.set_volume!('quiet')

    second_membership = @subgroup.membership_for(@normal_user)
    second_membership.set_volume!('quiet')

    put :set_volume, params: { id: membership.id, volume: 'loud' }

    membership.reload
    second_membership.reload

    assert_equal 'loud', membership.volume
    assert_not_equal 'loud', second_membership.volume
  end

  test 'updates volume for all memberships when apply_to_all is true' do
    @test_group.add_member!(@normal_user)
    @subgroup.add_member!(@normal_user)

    membership = @test_group.membership_for(@normal_user)
    membership.set_volume!('quiet')

    second_membership = @subgroup.membership_for(@normal_user)
    second_membership.set_volume!('quiet')

    put :set_volume, params: { id: membership.id, volume: 'loud', apply_to_all: true }

    membership.reload
    second_membership.reload

    assert_equal 'loud', membership.volume
    assert_equal 'loud', second_membership.volume
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
  end

  test 'responds with unauthorized for private groups when logged out' do
    private_group = Group.create!(
      name: 'Private Group',
      handle: 'privategroup',
      is_visible_to_public: false
    )

    sign_out @normal_user

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
    @test_group.add_member!(@another_user)

    get :for_user, params: { user_id: @another_user.id }

    json = JSON.parse(response.body)
    group_ids = json['groups'].map { |g| g['id'] }

    assert_includes group_ids, @test_group.id
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

    sign_out @normal_user

    post :save_experience, params: { id: membership.id, experience: :happiness }

    assert_response 403
  end

  # ===== Delegate Tests =====

  test 'make_delegate updates the membership record' do
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

    sign_in @another_user
    @test_group.add_member!(@another_user)
    membership = @test_group.add_member!(delegate_user)

    post :make_delegate, params: { id: membership.id }

    assert_response 403
    assert_equal false, membership.reload.delegate
  end

  test 'remove_delegate updates the membership record' do
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

    sign_in @another_user
    @test_group.add_member!(@another_user)

    post :remove_delegate, params: { id: membership.id }

    assert_response 403
    assert_equal true, membership.reload.delegate
  end
end
