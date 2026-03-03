require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
  end

  test "can create group" do
    assert @user.can?(:create, Group.new)
  end

  # is_visible_to_public
  test "public group visible to non member" do
    @group.update_columns(is_visible_to_public: true)
    assert @alien.can?(:show, @group)
  end

  test "public group visible to member" do
    @group.update_columns(is_visible_to_public: true)
    assert @user.can?(:show, @group)
  end

  test "hidden group not visible to non member" do
    @group.update_columns(is_visible_to_public: false)
    assert_not @alien.can?(:show, @group)
  end

  test "hidden group visible to member" do
    @group.update_columns(is_visible_to_public: false)
    assert @user.can?(:show, @group)
  end

  # is_visible_to_parent_members
  test "subgroup visible to parent members not visible to non member" do
    subgroup = groups(:subgroup)
    subgroup.update_columns(is_visible_to_parent_members: true, is_visible_to_public: false)
    assert_not @alien.can?(:show, subgroup)
  end

  test "subgroup visible to parent members visible to parent member" do
    subgroup = groups(:subgroup)
    subgroup.update_columns(is_visible_to_parent_members: true, is_visible_to_public: false)
    assert @user.can?(:show, subgroup)
  end

  test "subgroup visible to parent members visible to subgroup member" do
    subgroup = groups(:subgroup)
    subgroup_user = users(:subgroup_user)
    subgroup.update_columns(is_visible_to_parent_members: true, is_visible_to_public: false)
    assert subgroup_user.can?(:show, subgroup)
  end

  test "parent_members_can_see_discussions true" do
    subgroup = groups(:subgroup)
    subgroup.update_columns(parent_members_can_see_discussions: true, is_visible_to_parent_members: true, is_visible_to_public: false)
    discussion = DiscussionService.create(params: { group_id: subgroup.id, title: "Test", private: true }, actor: @admin)
    assert @user.can?(:show, discussion)
  end

  test "parent_members_can_see_discussions false" do
    subgroup = groups(:subgroup)
    subgroup.update_columns(parent_members_can_see_discussions: false, is_visible_to_parent_members: true, is_visible_to_public: false)
    discussion = DiscussionService.create(params: { group_id: subgroup.id, title: "Test", private: true }, actor: @admin)
    assert_not @user.can?(:show, discussion)
  end

  test "subgroup not visible to parent members not visible to non member" do
    subgroup = groups(:subgroup)
    subgroup.update_columns(is_visible_to_parent_members: false, is_visible_to_public: false)
    assert_not @alien.can?(:show, subgroup)
  end

  test "subgroup not visible to parent members not visible to parent member" do
    subgroup = groups(:subgroup)
    subgroup.update_columns(is_visible_to_parent_members: false, is_visible_to_public: false)
    assert_not @user.can?(:show, subgroup)
  end

  test "subgroup not visible to parent members parent group still visible" do
    subgroup = groups(:subgroup)
    subgroup.update_columns(is_visible_to_parent_members: false, is_visible_to_public: false)
    assert @user.can?(:show, @group)
  end

  # members_can_add_members
  test "members_can_add_members true non member cannot add" do
    @group.update_columns(members_can_add_members: true)
    assert_not @alien.can?(:add_members, @group)
  end

  test "members_can_add_members true member can add" do
    @group.update_columns(members_can_add_members: true)
    assert @user.can?(:add_members, @group)
  end

  test "members_can_add_members true admin can add" do
    @group.update_columns(members_can_add_members: true)
    assert @admin.can?(:add_members, @group)
  end

  test "members_can_add_members false non member cannot add" do
    @group.update_columns(members_can_add_members: false)
    assert_not @alien.can?(:add_members, @group)
  end

  test "members_can_add_members false member cannot add" do
    @group.update_columns(members_can_add_members: false)
    assert_not @user.can?(:add_members, @group)
  end

  test "members_can_add_members false admin can add" do
    @group.update_columns(members_can_add_members: false)
    assert @admin.can?(:add_members, @group)
  end

  # members_can_start_discussions
  test "members_can_start_discussions true member can create" do
    @group.update_columns(members_can_start_discussions: true)
    discussion = DiscussionService.build(params: { group_id: @group.id, title: "new" }, actor: @user)
    assert @user.can?(:create, discussion)
  end

  test "members_can_start_discussions false member cannot create" do
    @group.update_columns(members_can_start_discussions: false)
    discussion = DiscussionService.build(params: { group_id: @group.id, title: "new" }, actor: @user)
    assert_not @user.can?(:create, discussion)
  end

  # members_can_create_subgroups
  test "members_can_create_subgroups true member can create subgroup" do
    @group.update_columns(members_can_create_subgroups: true)
    assert @user.can?(:create, Group.new(parent: @group))
    assert @user.can?(:add_subgroup, @group)
  end

  test "members_can_create_subgroups false member cannot create subgroup" do
    @group.update_columns(members_can_create_subgroups: false)
    assert_not @user.can?(:create, Group.new(parent: @group))
    assert_not @user.can?(:add_subgroup, @group)
  end

  # Member of a group
  test "member permissions on group and discussions" do
    @group.update_columns(members_can_edit_discussions: false, members_can_start_discussions: true)

    pending_user = User.create!(name: "Pending #{SecureRandom.hex(4)}", email: "pending_#{SecureRandom.hex(4)}@test.com", email_verified: false)
    own_pending_membership = Membership.create!(user: pending_user, group: @group, inviter: @user, accepted_at: nil)
    other_pending = Membership.create!(
      user: User.create!(name: "OPend #{SecureRandom.hex(4)}", email: "opend_#{SecureRandom.hex(4)}@test.com", email_verified: false),
      group: @group, inviter: @admin
    )

    membership = @user.memberships.find_by(group: @group)
    admin_membership = @admin.memberships.find_by(group: @group)

    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test Discussion", private: true }, actor: @admin)
    comment = Comment.new(parent: discussion, author: @user)
    user_discussion = DiscussionService.create(params: { group_id: @group.id, title: "My Discussion", private: true }, actor: @user)
    new_discussion = DiscussionService.build(params: { group_id: @group.id, title: "new discussion" }, actor: @user)
    user_comment = Comment.create!(parent: discussion, body: "My comment", author: @user)
    admin_comment = Comment.create!(parent: discussion, body: "Their comment", author: @admin)

    assert @user.can?(:update, user_comment)
    assert_not @user.can?(:update, admin_comment)

    assert @user.can?(:show, @group)
    assert_not @user.can?(:update, @group)
    assert_not @user.can?(:email_members, @group)
    assert @user.can?(:create, comment)
    assert_not @user.can?(:move, discussion)
    assert @user.can?(:move, user_discussion)
    assert @user.can?(:update, user_discussion)
    assert @user.can?(:show, Discussion)
    assert @user.can?(:print, Discussion)
    assert @user.can?(:destroy, user_comment)
    assert_not @user.can?(:destroy, discussion)
    assert_not @user.can?(:destroy, admin_comment)
    assert @user.can?(:create, new_discussion)
    assert_not @user.can?(:make_admin, membership)
    assert_not @user.can?(:make_admin, admin_membership)
    assert_not @user.can?(:destroy, admin_membership)
    assert @user.can?(:destroy, membership)
    assert @user.can?(:destroy, own_pending_membership)
    assert_not @user.can?(:destroy, other_pending)
    assert @user.can?(:show, user_comment)
  end

  test "members_can_not_edit_comments and not most recent" do
    @group.update_columns(members_can_edit_comments: false)
    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test Discussion", private: true }, actor: @admin)
    user_comment = Comment.create!(parent: discussion, body: "My comment", author: @user)
    Comment.create!(parent: discussion, body: "Newer comment", author: @admin)
    assert_not @user.can?(:update, user_comment)
  end

  test "member with members_can_add_members true" do
    @group.update_columns(members_can_add_members: true)
    admin_membership = @admin.memberships.find_by(group: @group)
    requestor = User.create!(name: "Req #{SecureRandom.hex(4)}", email: "req_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    mr = MembershipRequest.create!(group: @group, requestor: requestor)

    assert @user.can?(:add_members, @group)
    assert @user.can?(:invite_people, @group)
    assert @user.can?(:manage_membership_requests, @group)
    assert @user.can?(:approve, mr)
    assert @user.can?(:ignore, mr)
    assert_not @user.can?(:destroy, admin_membership)
  end

  test "member with members_can_add_members false" do
    @group.update_columns(members_can_add_members: false)
    admin_membership = @admin.memberships.find_by(group: @group)
    requestor = User.create!(name: "Req #{SecureRandom.hex(4)}", email: "req_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    mr = MembershipRequest.create!(group: @group, requestor: requestor)

    assert_not @user.can?(:add_members, @group)
    assert_not @user.can?(:invite_people, @group)
    assert_not @user.can?(:manage_membership_requests, @group)
    assert_not @user.can?(:approve, mr)
    assert_not @user.can?(:ignore, mr)
    assert_not @user.can?(:destroy, admin_membership)
  end

  # Admin of a group
  test "admin permissions on group" do
    pending_user = User.create!(name: "Pend #{SecureRandom.hex(4)}", email: "pend_#{SecureRandom.hex(4)}@test.com", email_verified: false)
    own_pending = Membership.create!(user: pending_user, group: @group, inviter: @admin, accepted_at: nil)
    other_pending = Membership.create!(
      user: User.create!(name: "OPend #{SecureRandom.hex(4)}", email: "opend2_#{SecureRandom.hex(4)}@test.com", email_verified: false),
      group: @group, inviter: @user
    )

    subgroup = groups(:subgroup)
    subgroup_membership = @admin.memberships.find_by(group: subgroup)
    user_membership = @user.memberships.find_by(group: @group)

    discussion = DiscussionService.create(params: { group_id: @group.id, title: "Test", private: true }, actor: @admin)
    user_comment = Comment.create!(parent: discussion, body: "comment", author: @user)
    requestor = User.create!(name: "Req #{SecureRandom.hex(4)}", email: "req_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    mr = MembershipRequest.create!(group: @group, requestor: requestor)

    assert @admin.can?(:update, @group)
    assert @admin.can?(:email_members, @group)
    assert @admin.can?(:destroy, discussion)
    assert @admin.can?(:move, discussion)
    assert @admin.can?(:update, discussion)
    assert @admin.can?(:make_admin, user_membership)
    assert @admin.can?(:make_admin, subgroup_membership)
    assert @admin.can?(:remove_admin, user_membership)
    assert @admin.can?(:destroy, user_membership)
    assert @admin.can?(:destroy, user_comment)
    assert @admin.can?(:destroy, own_pending)
    assert @admin.can?(:destroy, other_pending)
  end

  test "admin can become admin if no other admins" do
    membership = @admin.memberships.find_by(group: @group)
    membership.update!(admin: false)
    @group.admin_memberships.destroy_all
    assert @admin.can?(:make_admin, membership)
  end

  test "member cannot become admin if other admins exist" do
    membership = @user.memberships.find_by(group: @group)
    assert_not @user.can?(:make_admin, membership)
  end

  test "admin with members_can_add_members false can still add" do
    @group.update_columns(members_can_add_members: false)
    requestor = User.create!(name: "Req #{SecureRandom.hex(4)}", email: "req_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    mr = MembershipRequest.create!(group: @group, requestor: requestor)

    assert @admin.can?(:add_members, @group)
    assert @admin.can?(:invite_people, @group)
    assert @admin.can?(:manage_membership_requests, @group)
    assert @admin.can?(:approve, mr)
    assert @admin.can?(:ignore, mr)
  end

  # Non member of hidden group
  test "non member of hidden group permissions" do
    @group.update_columns(is_visible_to_public: false)
    discussion = discussions(:discussion)
    new_discussion = DiscussionService.build(params: { group_id: @group.id, title: "title" }, actor: @alien)
    user_comment = Comment.new(parent: discussion, author: @alien)
    admin_comment = Comment.create!(parent: discussion, body: "comment", author: @admin)

    assert_not @alien.can?(:show, @group)
    assert_not @alien.can?(:update, @group)
    assert_not @alien.can?(:email_members, @group)
    assert_not @alien.can?(:add_members, @group)
    assert_not @alien.can?(:hide_next_steps, @group)
    assert_not @alien.can?(:unfollow, @group)
    assert_not @alien.can?(:create, new_discussion)
    assert_not @alien.can?(:show, discussion)
    assert_not @alien.can?(:print, discussion)
    assert_not @alien.can?(:create, user_comment)
    assert_not @alien.can?(:move, discussion)
    assert_not @alien.can?(:destroy, discussion)
    assert_not @alien.can?(:like, admin_comment)
    assert_not @alien.can?(:destroy, admin_comment)
    assert_not @alien.can?(:show, admin_comment)
  end

  # Non member of public group
  test "non member of public group permissions" do
    group = Group.create!(name: "Public #{SecureRandom.hex(4)}", group_privacy: 'closed',
                          is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    other_admin = User.create!(name: "PubAdmin #{SecureRandom.hex(4)}", email: "pubadmin_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    group.add_admin!(other_admin)

    private_discussion = DiscussionService.create(params: { group_id: group.id, title: "Private", private: true }, actor: other_admin)
    public_discussion = DiscussionService.create(params: { group_id: group.id, title: "Public", private: false }, actor: other_admin)
    comment_in_private = Comment.new(parent: private_discussion, author: @user, body: 'hi')
    comment_in_public = Comment.new(parent: public_discussion, author: @user, body: 'hi')
    new_discussion = DiscussionService.build(params: { group_id: group.id, title: "new discussion" }, actor: @user)
    admin_comment = Comment.create!(parent: private_discussion, body: "comment", author: other_admin)
    requestor = User.create!(name: "MRReq #{SecureRandom.hex(4)}", email: "mrreq_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    my_mr = MembershipRequest.create!(group: group, requestor: @user)
    other_mr = MembershipRequest.create!(group: group, requestor: requestor)

    assert @user.can?(:show, group)
    assert_not @user.can?(:update, group)
    assert_not @user.can?(:email_members, group)
    assert_not @user.can?(:add_members, group)
    assert_not @user.can?(:manage_membership_requests, group)
    assert_not @user.can?(:hide_next_steps, group)
    assert_not @user.can?(:unfollow, group)

    assert @user.can?(:cancel, my_mr)
    assert_not @user.can?(:cancel, other_mr)
    assert_not @user.can?(:approve, other_mr)
    assert_not @user.can?(:ignore, other_mr)

    assert_not @user.can?(:create, new_discussion)
    assert_not @user.can?(:show, private_discussion)
    assert_not @user.can?(:print, private_discussion)
    assert_not @user.can?(:create, comment_in_private)
    assert_not @user.can?(:move, private_discussion)
    assert_not @user.can?(:destroy, private_discussion)

    assert @user.can?(:show, public_discussion)
    assert @user.can?(:print, public_discussion)
    assert_not @user.can?(:create, comment_in_public)
    assert_not @user.can?(:move, public_discussion)
    assert_not @user.can?(:destroy, public_discussion)

    assert_not @user.can?(:destroy, admin_comment)
    assert_not @user.can?(:like, admin_comment)
  end

  # Loomio admin
  test "loomio admin can deactivate other user" do
    @user.is_admin = true
    assert @user.can?(:deactivate, @alien)
  end
end
