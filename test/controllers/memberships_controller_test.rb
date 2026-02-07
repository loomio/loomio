require 'test_helper'

class MembershipsControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "memuser#{hex}", email: "memuser#{hex}@example.com", username: "memuser#{hex}", email_verified: true)
    @another_user = User.create!(name: "memoth#{hex}", email: "memoth#{hex}@example.com", username: "memoth#{hex}", email_verified: true)
    @invitee = User.create!(name: "invitee#{hex}", email: "invitee#{hex}@example.com", username: "invitee#{hex}", email_verified: true)
    @group = Group.new(name: "memgroup#{hex}", group_privacy: 'closed', handle: "memgroup#{hex}")
    @group.creator = @user
    @group.save!
    @group.add_admin!(@user)
    ActionMailer::Base.deliveries.clear
  end

  # Redeem tests — use separate groups for consume tests since @user is already admin of @group
  test "redeem pending membership" do
    hex = SecureRandom.hex(4)
    redeem_group = Group.new(name: "redeem#{hex}", group_privacy: 'closed', handle: "redeem#{hex}")
    redeem_group.creator = @another_user
    redeem_group.save!
    membership = Membership.create!(group: redeem_group, user: @invitee, accepted_at: nil)
    session[:pending_membership_token] = membership.token
    sign_in @user

    assert_nil membership.accepted_at
    assert_difference 'Event.count', 1 do
      get :consume
    end
    assert_response 200
    membership.reload
    assert_not_nil membership.accepted_at
    assert_equal @user.id, membership.user_id
  end

  test "redeem multiple pending memberships in same org" do
    hex = SecureRandom.hex(4)
    redeem_group = Group.new(name: "redeem#{hex}", group_privacy: 'closed', handle: "redeem#{hex}")
    redeem_group.creator = @another_user
    redeem_group.save!
    membership = Membership.create!(group: redeem_group, user: @invitee, accepted_at: nil)
    subgroup = Group.new(name: "sub#{SecureRandom.hex(4)}", parent: redeem_group, group_privacy: 'secret', handle: "#{redeem_group.handle}-sub#{SecureRandom.hex(4)}")
    subgroup.creator = @another_user
    subgroup.save!
    subgroup_membership = Membership.create!(group: subgroup, user: @invitee, accepted_at: nil)

    session[:pending_membership_token] = membership.token
    sign_in @user

    assert_difference 'Event.count', 1 do
      get :consume
    end
    assert_response 200
    membership.reload
    subgroup_membership.reload
    assert_not_nil membership.accepted_at
    assert_equal @user.id, membership.user_id
    assert_not_nil subgroup_membership.accepted_at
    assert_equal @user.id, subgroup_membership.user_id
  end

  test "redeem ignores when already member" do
    membership = Membership.create!(group: @group, user: @invitee, accepted_at: nil)
    session[:pending_membership_token] = membership.token
    sign_in @user  # @user is already admin of @group

    assert_no_difference 'Event.count' do
      get :consume
    end
    assert_response 200
    refute Membership.where(id: membership.id).exists?
  end

  test "does not redeem accepted membership" do
    hex = SecureRandom.hex(4)
    redeem_group = Group.new(name: "redeem#{hex}", group_privacy: 'closed', handle: "redeem#{hex}")
    redeem_group.creator = @another_user
    redeem_group.save!
    membership = Membership.create!(group: redeem_group, user: @invitee, accepted_at: Time.zone.now)
    session[:pending_membership_token] = membership.token
    sign_in @user

    assert_no_difference 'Event.count' do
      get :consume
    end
    assert_response 200
    membership.reload
    assert_not_equal @user.id, membership.user_id
  end

  # Join test
  test "stores pending_group_token in session" do
    get :join, params: { model: 'group', token: @group.token }
    assert_equal @group.token, session[:pending_group_token]
    assert_redirected_to "/#{@group.handle}"
  end

  # Show tests
  test "show membership not found" do
    get :show, params: { token: 'asdjhadjkhaskjdsahda' }
    assert_response 404
  end

  test "show membership used redirects to group" do
    membership = Membership.create!(group: @group, user: @invitee, accepted_at: nil)
    sign_in @invitee
    membership.update_attribute(:accepted_at, Time.now)
    get :show, params: { token: membership.token }
    assert_redirected_to "/#{@group.handle}"
  end

  test "show redirects to group if already a member" do
    @group.add_member!(@another_user)
    sign_in @another_user
    membership = Membership.create!(group: @group, user: @invitee, accepted_at: nil)
    get :show, params: { token: membership.token }
    assert_redirected_to "/#{@group.handle}"
  end

  test "show sets session token when not signed in" do
    membership = Membership.create!(group: @group, user: @invitee, accepted_at: nil)
    get :show, params: { token: membership.token }
    assert_equal membership.token, session[:pending_membership_token]
    assert_redirected_to "/#{@group.handle}"
  end

  test "show does not accept membership when not signed in" do
    membership = Membership.create!(group: @group, user: @invitee, accepted_at: nil)
    get :show, params: { token: membership.token }
    membership.reload
    refute membership.accepted_at.present?
  end

  test "join redirects to group url with group token" do
    get :join, params: { token: @group.token, model: :group }
    assert_response 302
    assert_redirected_to "/#{@group.handle}"
  end

  test "show accepts and redirects to group" do
    membership = Membership.create!(group: @group, user: @invitee, accepted_at: nil)
    get :show, params: { token: membership.token }
    membership.reload
    refute membership.accepted_at.present?
    assert_redirected_to "/#{@group.handle}"
  end
end
