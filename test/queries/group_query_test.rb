require 'test_helper'

class GroupQueryTest < ActiveSupport::TestCase
  test "parent members list public and parent-visible subgroups using the access matrix" do
    subgroup = groups(:parent_join_subgroup)
    subgroup.parent.update!(group_privacy: 'closed')
    parent_roles = %i[admin member_normal reader_normal member_guest_loud]
    outsider_roles = %i[alien guest_normal non_guest_loud former_member_loud former_member_guest inactive_member_loud]

    %w[open closed parent_members secret].each do |privacy|
      subgroup.update!(group_privacy: privacy)
      (parent_roles + outsider_roles).each do |role|
        expected = parent_roles.include?(role) && privacy != 'secret'
        assert_equal expected, GroupQuery.visible_to(user: users(role)).exists?(subgroup.id), "#{role}, #{privacy}"
      end
      assert_not GroupQuery.visible_to.exists?(subgroup.id)
      assert_not GroupQuery.visible_to(user: users(:member_normal)).exists?(groups(:public_group).id)
    end
  end

  test "thread guests see group context without inheriting subgroup access or changing membership ids" do
    guest = users(:guest_normal)
    parent = groups(:group)
    subgroup = groups(:parent_join_subgroup)
    membership_ids = guest.group_ids.dup

    2.times do
      visible = GroupQuery.visible_to(user: guest)
      assert visible.exists?(parent.id)
      assert_not visible.exists?(subgroup.id)
      assert_equal membership_ids, guest.group_ids
    end
  end

  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "gquser#{hex}", email: "gquser#{hex}@example.com", username: "gquser#{hex}")

    @group = Group.new(name: "group#{hex}", group_privacy: 'secret')
    @group.save(validate: false)

    @parent = Group.new(name: "parent#{hex}", group_privacy: 'secret')
    @parent.save(validate: false)

    @subgroup = Group.new(name: "subgroup#{hex}", parent: @parent, group_privacy: 'secret')
    @subgroup.save(validate: false)
    @subgroup.update_columns(is_visible_to_parent_members: true)

    @rando = Group.new(name: "rando#{hex}", group_privacy: 'secret')
    @rando.save(validate: false)

    @public_group = Group.new(name: "public#{hex}", group_privacy: 'open')
    @public_group.save(validate: false)

    @group.add_member!(@user)
    @parent.add_member!(@user)
  end

  test "finds groups the user can see" do
    results = GroupQuery.visible_to(user: @user)
    assert_includes results, @group
    assert_includes results, @subgroup
    assert_includes results, @parent
    refute_includes results, @rando
  end

  test "deactivated users cannot see groups" do
    @user.update!(deactivated_at: Time.current)

    assert_empty GroupQuery.visible_to(user: @user, show_public: true)
  end

  test "finds groups the user can see and public groups" do
    results = GroupQuery.visible_to(user: @user, show_public: true)
    assert_includes results, @group
    assert_includes results, @subgroup
    assert_includes results, @parent
    assert_includes results, @public_group
    refute_includes results, @rando
  end

  test "finds public groups" do
    results = GroupQuery.visible_to(show_public: true)
    assert_includes results, @public_group
    refute_includes results, @rando
    refute_includes results, @group
    refute_includes results, @subgroup
    refute_includes results, @parent
  end
end
