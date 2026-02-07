require 'test_helper'

class Events::NewCoordinatorTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Coord User #{SecureRandom.hex(4)}", email: "coord_#{SecureRandom.hex(4)}@test.com")
    @group = Group.create!(name: "Coord Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
    @group.add_member!(@user)
    @membership = @user.memberships.find_by(group: @group)
  end

  test "creates an event" do
    assert_difference -> { Event.where(kind: 'new_coordinator').count }, 1 do
      Events::NewCoordinator.publish!(@membership, @user)
    end
  end

  test "returns an event" do
    result = Events::NewCoordinator.publish!(@membership, @user)
    assert_kind_of Event, result
  end
end
