require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  def can?(action, subject)
    @ability.can?(action, subject)
  end

  def cannot?(action, subject)
    !@ability.can?(action, subject)
  end

  setup do
    @user = users(:normal_user)
    @other_user = users(:another_user)
    @non_member = users(:discussion_author)
    @ability = Ability::Base.new(@user)
  end

  test "can create group" do
    group = Group.new
    assert can?(:create, group)
  end

  # is_visible_to_public
  test "public group visible to non member" do
    group = Group.create!(name: "Pub #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:is_visible_to_public, true)
    assert can?(:show, group)
  end

  test "public group visible to member" do
    group = Group.create!(name: "Pub #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:is_visible_to_public, true)
    group.add_member!(@user)
    assert can?(:show, group)
  end

  test "hidden group not visible to non member" do
    group = Group.create!(name: "Hid #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:is_visible_to_public, false)
    assert cannot?(:show, group)
  end

  test "hidden group visible to member" do
    group = Group.create!(name: "Hid #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:is_visible_to_public, false)
    group.add_member!(@user)
    assert can?(:show, group)
  end

  # is_visible_to_parent_members
  test "subgroup visible to parent members not visible to non member" do
    group = Group.create!(name: "Par #{SecureRandom.hex(4)}", group_privacy: 'secret')
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: group, is_visible_to_public: false)
    subgroup.update_attribute(:is_visible_to_parent_members, true)
    assert cannot?(:show, subgroup)
  end

  test "subgroup visible to parent members visible to parent member" do
    group = Group.create!(name: "Par #{SecureRandom.hex(4)}", group_privacy: 'secret')
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: group, is_visible_to_public: false)
    subgroup.update_attribute(:is_visible_to_parent_members, true)
    group.add_member!(@user)
    assert can?(:show, subgroup)
  end

  test "subgroup visible to parent members visible to subgroup member" do
    group = Group.create!(name: "Par #{SecureRandom.hex(4)}", group_privacy: 'secret')
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: group, is_visible_to_public: false)
    subgroup.update_attribute(:is_visible_to_parent_members, true)
    subgroup.add_member!(@user)
    assert can?(:show, subgroup)
  end

  test "parent_members_can_see_discussions true" do
    group = Group.create!(name: "Par #{SecureRandom.hex(4)}", group_privacy: 'secret')
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: group, is_visible_to_public: false, is_visible_to_parent_members: true)
    subgroup.update_attribute(:parent_members_can_see_discussions, true)
    group.add_member!(@user)
    author = User.create!(name: "Author #{SecureRandom.hex(4)}", email: "author_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    subgroup.add_admin!(author)
    discussion = Discussion.create!(group: subgroup, title: "Test", private: true, author: author)
    assert can?(:show, discussion)
  end

  test "parent_members_can_see_discussions false" do
    group = Group.create!(name: "Par #{SecureRandom.hex(4)}", group_privacy: 'secret')
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: group, is_visible_to_public: false, is_visible_to_parent_members: true)
    subgroup.update_attribute(:parent_members_can_see_discussions, false)
    group.add_member!(@user)
    author = User.create!(name: "Author #{SecureRandom.hex(4)}", email: "author_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    subgroup.add_admin!(author)
    discussion = Discussion.create!(group: subgroup, title: "Test", private: true, author: author)
    assert cannot?(:show, discussion)
  end

  test "subgroup not visible to parent members not visible to non member" do
    group = Group.create!(name: "Par #{SecureRandom.hex(4)}", group_privacy: 'secret')
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: group, is_visible_to_public: false)
    subgroup.update_attribute(:is_visible_to_parent_members, false)
    assert cannot?(:show, subgroup)
  end

  test "subgroup not visible to parent members not visible to parent member" do
    group = Group.create!(name: "Par #{SecureRandom.hex(4)}", group_privacy: 'secret')
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: group, is_visible_to_public: false)
    subgroup.update_attribute(:is_visible_to_parent_members, false)
    group.add_member!(@user)
    assert cannot?(:show, subgroup)
  end

  test "subgroup not visible to parent members parent group still visible" do
    group = Group.create!(name: "Par #{SecureRandom.hex(4)}", group_privacy: 'secret')
    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: group, is_visible_to_public: false)
    subgroup.update_attribute(:is_visible_to_parent_members, false)
    group.add_member!(@user)
    assert can?(:show, group)
  end

  # members_can_add_members
  test "members_can_add_members true non member cannot add" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_add_members, true)
    assert cannot?(:add_members, group)
  end

  test "members_can_add_members true member can add" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_add_members, true)
    group.add_member!(@user)
    assert can?(:add_members, group)
  end

  test "members_can_add_members true admin can add" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_add_members, true)
    group.add_admin!(@user)
    assert can?(:add_members, group)
  end

  test "members_can_add_members false non member cannot add" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_add_members, false)
    assert cannot?(:add_members, group)
  end

  test "members_can_add_members false member cannot add" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_add_members, false)
    group.add_member!(@user)
    assert cannot?(:add_members, group)
  end

  test "members_can_add_members false admin can add" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_add_members, false)
    group.add_admin!(@user)
    assert can?(:add_members, group)
  end

  # members_can_start_discussions
  test "members_can_start_discussions true member can create" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_start_discussions, true)
    group.add_member!(@user)
    assert can?(:create, Discussion.new(group: group))
  end

  test "members_can_start_discussions false member cannot create" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_start_discussions, false)
    group.add_member!(@user)
    assert cannot?(:create, Discussion.new(group: group))
  end

  # members_can_create_subgroups
  test "members_can_create_subgroups true member can create subgroup" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_create_subgroups, true)
    group.add_member!(@user)
    assert can?(:create, Group.new(parent: group))
    assert can?(:add_subgroup, group)
  end

  test "members_can_create_subgroups false member cannot create subgroup" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_create_subgroups, false)
    group.add_member!(@user)
    assert cannot?(:create, Group.new(parent: group))
    assert cannot?(:add_subgroup, group)
  end

  # Member of a group
  test "member permissions on group and discussions" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret',
                          members_can_edit_discussions: false,
                          members_can_start_discussions: true)
    # Need an admin first so the group is properly set up
    admin = User.create!(name: "Grp Admin #{SecureRandom.hex(4)}", email: "grpadmin_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    group.add_admin!(admin)

    pending_user = User.create!(name: "Pending #{SecureRandom.hex(4)}", email: "pending_#{SecureRandom.hex(4)}@test.com", email_verified: false)
    own_pending_membership = Membership.create!(user: pending_user, group: group, inviter: @user, accepted_at: nil)
    other_pending = Membership.create!(
      user: User.create!(name: "OPend #{SecureRandom.hex(4)}", email: "opend_#{SecureRandom.hex(4)}@test.com", email_verified: false),
      group: group, inviter: @other_user
    )

    membership = group.add_member!(@user)
    other_membership = group.add_member!(@other_user)

    discussion = Discussion.create!(group: group, title: "Test Discussion", private: true, author: admin)
    comment = Comment.new(parent: discussion, author: @user)
    user_discussion = Discussion.create!(group: group, title: "My Discussion", private: true, author: @user)
    new_discussion = @user.authored_discussions.new(group: group, title: "new discussion")
    user_comment = Comment.create!(parent: discussion, body: "My comment", author: @user)
    another_user_comment = Comment.create!(parent: discussion, body: "Their comment", author: @other_user)

    # members_can_edit_comments (default true)
    assert can?(:update, user_comment)
    assert cannot?(:update, another_user_comment)

    assert can?(:show, group)
    assert cannot?(:update, group)
    assert cannot?(:email_members, group)
    assert cannot?(:create, Group.new(parent: Group.create!(name: "Other #{SecureRandom.hex(4)}", group_privacy: 'secret')))
    assert can?(:create, comment)
    assert cannot?(:move, discussion)
    assert can?(:move, user_discussion)
    assert can?(:update, user_discussion)
    assert can?(:show, Discussion)
    assert can?(:print, Discussion)
    assert can?(:destroy, user_comment)
    assert cannot?(:destroy, discussion)
    assert cannot?(:destroy, another_user_comment)
    assert can?(:create, new_discussion)
    assert cannot?(:make_admin, membership)
    assert cannot?(:make_admin, other_membership)
    assert cannot?(:destroy, other_membership)
    assert can?(:destroy, membership)
    assert can?(:destroy, own_pending_membership)
    assert cannot?(:destroy, other_pending)
    assert can?(:show, user_comment)
  end

  test "members_can_not_edit_comments and not most recent" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret', members_can_edit_comments: false)
    group.add_member!(@user)
    group.add_member!(@other_user)
    author = group.memberships.where(admin: true).first&.user || @user
    discussion = Discussion.create!(group: group, title: "Test Discussion", private: true, author: author)
    user_comment = Comment.create!(parent: discussion, body: "My comment", author: @user)
    Comment.create!(parent: discussion, body: "Newer comment", author: @other_user)
    assert cannot?(:update, user_comment)
  end

  test "member with members_can_add_members true" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_add_members, true)
    membership = group.add_member!(@user)
    other_membership = group.add_member!(@other_user)
    mr = MembershipRequest.create!(group: group, requestor: @non_member)

    assert can?(:add_members, group)
    assert can?(:invite_people, group)
    assert can?(:manage_membership_requests, group)
    assert can?(:approve, mr)
    assert can?(:ignore, mr)
    assert cannot?(:destroy, other_membership)
  end

  test "member with members_can_add_members false" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_add_members, false)
    membership = group.add_member!(@user)
    other_membership = group.add_member!(@other_user)
    mr = MembershipRequest.create!(group: group, requestor: @non_member)

    assert cannot?(:add_members, group)
    assert cannot?(:invite_people, group)
    assert cannot?(:manage_membership_requests, group)
    assert cannot?(:approve, mr)
    assert cannot?(:ignore, mr)
    assert cannot?(:destroy, other_membership)
  end

  # Admin of a group
  test "admin permissions on group" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    pending_user = User.create!(name: "Pend #{SecureRandom.hex(4)}", email: "pend_#{SecureRandom.hex(4)}@test.com", email_verified: false)
    own_pending = Membership.create!(user: pending_user, group: group, inviter: @user, accepted_at: nil)
    other_pending = Membership.create!(
      user: User.create!(name: "OPend #{SecureRandom.hex(4)}", email: "opend2_#{SecureRandom.hex(4)}@test.com", email_verified: false),
      group: group, inviter: @other_user
    )

    subgroup = Group.create!(name: "Sub #{SecureRandom.hex(4)}", parent: group, group_privacy: 'secret')
    closed_subgroup = Group.create!(name: "Closed Sub #{SecureRandom.hex(4)}", parent: group, group_privacy: 'closed')

    membership = group.add_admin!(@user)
    subgroup_membership = subgroup.add_member!(@user)
    other_membership = group.add_member!(@other_user)

    discussion = Discussion.create!(group: group, title: "Test", private: true, author: @user)
    another_user_comment = Comment.create!(parent: discussion, body: "comment", author: @other_user)
    mr = MembershipRequest.create!(group: group, requestor: @non_member)

    assert can?(:update, group)
    assert can?(:email_members, group)
    assert can?(:destroy, discussion)
    assert can?(:move, discussion)
    assert can?(:update, discussion)
    assert can?(:make_admin, other_membership)
    assert can?(:make_admin, subgroup_membership)
    assert can?(:remove_admin, other_membership)
    assert can?(:destroy, other_membership)
    assert can?(:destroy, another_user_comment)
    assert can?(:destroy, own_pending)
    assert can?(:destroy, other_pending)
    assert can?(:join, closed_subgroup)
  end

  test "admin can become admin if no other admins" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    membership = group.add_admin!(@user)
    membership.update!(admin: false)
    group.admin_memberships.destroy_all
    assert can?(:make_admin, membership)
  end

  test "member cannot become admin if other admins exist" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    membership = group.add_admin!(@user)
    group.add_admin!(@other_user)
    membership.update!(admin: false)
    assert cannot?(:make_admin, membership)
  end

  test "admin with members_can_add_members false can still add" do
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.update_attribute(:members_can_add_members, false)
    group.add_admin!(@user)
    mr = MembershipRequest.create!(group: group, requestor: @non_member)

    assert can?(:add_members, group)
    assert can?(:invite_people, group)
    assert can?(:manage_membership_requests, group)
    assert can?(:approve, mr)
    assert can?(:ignore, mr)
  end

  # Non member of hidden group
  test "non member of hidden group permissions" do
    group = Group.create!(name: "Hidden #{SecureRandom.hex(4)}", group_privacy: 'secret', is_visible_to_public: false)
    group.add_admin!(@other_user)
    discussion = Discussion.create!(group: group, title: "Private", private: true, author: @other_user)
    new_discussion = Discussion.new(group: group, author: @user, title: 'title')
    user_comment = Comment.new(parent: discussion, author: @user)
    another_user_comment = Comment.create!(parent: discussion, body: "comment", author: @other_user)

    assert cannot?(:show, group)
    assert cannot?(:update, group)
    assert cannot?(:email_members, group)
    assert cannot?(:add_members, group)
    assert cannot?(:hide_next_steps, group)
    assert cannot?(:unfollow, group)
    assert cannot?(:create, new_discussion)
    assert cannot?(:show, discussion)
    assert cannot?(:print, discussion)
    assert cannot?(:create, user_comment)
    assert cannot?(:move, discussion)
    assert cannot?(:destroy, discussion)
    assert cannot?(:like, another_user_comment)
    assert cannot?(:destroy, another_user_comment)
    assert cannot?(:show, another_user_comment)
  end

  # Non member of public group
  test "non member of public group permissions" do
    group = Group.create!(name: "Public #{SecureRandom.hex(4)}", group_privacy: 'closed',
                          is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    other_admin = User.create!(name: "PubAdmin #{SecureRandom.hex(4)}", email: "pubadmin_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    group.add_admin!(other_admin)

    private_discussion = Discussion.create!(group: group, title: "Private", private: true, author: other_admin)
    public_discussion = Discussion.create!(group: group, title: "Public", private: false, author: other_admin)
    comment_in_private = Comment.new(parent: private_discussion, author: @user, body: 'hi')
    comment_in_public = Comment.new(parent: public_discussion, author: @user, body: 'hi')
    new_discussion = @user.authored_discussions.new(group: group, title: "new discussion")
    another_user_comment = Comment.create!(parent: private_discussion, body: "comment", author: other_admin)
    mr_requestor = User.create!(name: "MRReq #{SecureRandom.hex(4)}", email: "mrreq_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    my_mr = MembershipRequest.create!(group: group, requestor: @user)
    other_mr = MembershipRequest.create!(group: group, requestor: mr_requestor)

    assert can?(:show, group)
    assert cannot?(:update, group)
    assert cannot?(:email_members, group)
    assert cannot?(:add_members, group)
    assert cannot?(:manage_membership_requests, group)
    assert cannot?(:hide_next_steps, group)
    assert cannot?(:unfollow, group)

    assert can?(:cancel, my_mr)
    assert cannot?(:cancel, other_mr)
    assert cannot?(:approve, other_mr)
    assert cannot?(:ignore, other_mr)

    assert cannot?(:create, new_discussion)
    assert cannot?(:show, private_discussion)
    assert cannot?(:print, private_discussion)
    assert cannot?(:create, comment_in_private)
    assert cannot?(:move, private_discussion)
    assert cannot?(:destroy, private_discussion)

    assert can?(:show, public_discussion)
    assert can?(:print, public_discussion)
    assert cannot?(:create, comment_in_public)
    assert cannot?(:move, public_discussion)
    assert cannot?(:destroy, public_discussion)

    assert cannot?(:destroy, another_user_comment)
    assert cannot?(:like, another_user_comment)
  end

  # Loomio admin
  test "loomio admin can deactivate other user" do
    @user.is_admin = true
    @ability = Ability::Base.new(@user)
    group = Group.create!(name: "Grp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.add_member!(@other_user)
    assert can?(:deactivate, @other_user)
  end
end
