require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @alien = users(:alien)
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
    alien_group = groups(:alien_group)
    membership = @user.memberships.new(group_id: alien_group.id)
    membership.inviter = @alien
    membership.save!
    assert_equal @alien, membership.inviter
  end

  test "responds to volume" do
    @group.add_member!(@user)
    membership = @user.memberships.find_by(group: @group)
    membership.update!(volume_email: :normal)
    assert_equal :normal, membership.volume_email.to_sym
  end

  test "delivery channels use the quiet normal loud volume scale" do
    levels = { "quiet" => 1, "normal" => 2, "loud" => 3 }

    assert_equal levels, Membership.volume_emails
    assert_equal levels, Membership.volume_pushes
    assert_equal levels, User.volume_email_defaults
    assert_equal levels, User.volume_push_defaults
  end

  test "delivery preferences default to normal across records" do
    assert_predicate User.new, :email_default_normal?
    assert_predicate User.new, :push_default_normal?
    assert_predicate Membership.new, :email_normal?
    assert_predicate Membership.new, :push_normal?
    assert_predicate TopicReader.new, :email_normal?
    assert_predicate TopicReader.new, :push_normal?
  end

  test "active and admin scopes match the fixture membership matrix exactly" do
    active = users(
      :admin,
      :user,
      :member,
      :member_quiet,
      :member_normal,
      :member_loud,
      :inactive_member_loud,
      :reader_quiet,
      :reader_normal,
      :reader_loud,
      :member_guest_loud
    )
    admins = users(:admin, :inactive_member_loud)

    assert_equal active.map(&:id).sort, @group.memberships.pluck(:user_id).sort
    assert_equal admins.map(&:id).sort, @group.admin_memberships.pluck(:user_id).sort
  end

  test "permission membership lookups agree from the user and group sides" do
    matrix_users = users(
      :admin,
      :user,
      :member,
      :member_quiet,
      :member_normal,
      :member_loud,
      :guest_quiet,
      :guest_normal,
      :guest_admin_normal,
      :guest_loud,
      :alien,
      :alien_quiet,
      :alien_loud,
      :non_guest_loud,
      :former_member_loud,
      :former_guest_loud,
      :inactive_member_loud,
      :inactive_guest_loud,
      :reader_quiet,
      :reader_normal,
      :reader_loud,
      :member_guest_loud,
      :former_member_guest
    )

    matrix_users.each do |user|
      assert_equal @group.memberships.exists?(user: user), user.memberships.exists?(group: @group), user.email
      assert_equal @group.admin_memberships.exists?(user: user), user.admin_memberships.exists?(group: @group), user.email
    end
  end

  test "can change its volume" do
    @group.add_member!(@user)
    membership = @user.memberships.find_by(group: @group)
    membership.update!(volume_email: :normal)
    membership.set_volume!(email: :quiet, push: :normal)
    assert_equal :quiet, membership.reload.volume_email.to_sym
    assert_equal :normal, membership.volume_push.to_sym
  end
end
