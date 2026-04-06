require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @user2 = users(:alien)
    @group = groups(:group)
  end

  test "cannot have duplicate memberships" do
    @group.add_member!(@user)
    duplicate = Membership.new(user: @user, group: @group)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "generates a token on initialize" do
    membership = Membership.new
    assert membership.token.present?
  end

  test "can have an inviter" do
    group = groups(:alien_group)
    membership = @user.memberships.new(group_id: group.id)
    membership.inviter = @user2
    membership.save!
    assert_equal @user2, membership.inviter
  end

  test "responds to volume" do
    @group.add_member!(@user)
    membership = @user.memberships.find_by(group: @group)
    membership.update!(volume: :normal)
    assert_equal :normal, membership.volume.to_sym
  end

  test "can change its volume" do
    @group.add_member!(@user)
    membership = @user.memberships.find_by(group: @group)
    membership.update!(volume: :normal)
    membership.set_volume!(:quiet)
    assert_equal :quiet, membership.reload.volume.to_sym
  end
end
