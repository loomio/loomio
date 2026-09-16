require "test_helper"

class GroupFollowTest < ActiveSupport::TestCase
  test "a non-member can follow a group once" do
    follow = GroupFollow.create!(group: groups(:public_group), user: users(:alien))

    assert follow.persisted?
    assert_raises ActiveRecord::RecordInvalid do
      GroupFollow.create!(group: follow.group, user: follow.user)
    end
  end

  test "a group member cannot follow the group" do
    group = groups(:public_group)
    user = users(:user)
    group.add_member!(user)

    follow = GroupFollow.new(group: group, user: user)

    refute follow.valid?
  end

  test "creating a membership removes an existing follow" do
    group = groups(:public_group)
    user = users(:alien)
    GroupFollow.create!(group: group, user: user)

    assert_difference "GroupFollow.count", -1 do
      group.add_member!(user)
    end
  end
end
