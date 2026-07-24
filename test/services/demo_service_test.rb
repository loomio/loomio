require 'test_helper'

class DemoServiceTest < ActiveSupport::TestCase
  setup do
    DemoService.reset_queue!
  end

  teardown do
    DemoService.reset_queue!
  end

  test "taking a demo makes the group invitation only" do
    actor = users(:user)
    group = Group.create!(
      name: "Demo source #{SecureRandom.hex(4)}",
      creator: users(:admin),
      group_privacy: 'open',
      membership_granted_upon: 'request'
    )
    DemoService.write_demo_group_ids([group.id])

    demo_group = DemoService.take_demo(actor)

    assert_equal 'invitation', demo_group.membership_granted_upon
    refute users(:alien).ability.can?(:join, demo_group)
  end
end
