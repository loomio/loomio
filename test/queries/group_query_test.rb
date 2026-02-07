require 'test_helper'

class GroupQueryTest < ActiveSupport::TestCase
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
