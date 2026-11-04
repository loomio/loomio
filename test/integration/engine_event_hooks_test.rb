require "test_helper"

class EngineEventHooksTest < ActiveSupport::TestCase
  test "optional engines receive a persisted new group and its creator" do
    group = Group.new(name: "Engine hook group", handle: "engine-hook-#{SecureRandom.hex(4)}")
    actor = users(:user)

    capture_engine_event("group_create") do |events|
      GroupService.create(group: group, actor: actor)
      assert_equal [[group, actor]], events
      assert group.persisted?
      assert_equal actor, group.reload.creator
    end
  end

  test "optional engines receive a discarded group only after commit" do
    group = topics(:discussion_topic).group
    actor = users(:admin)

    capture_engine_event("group_destroy") do |events|
      Group.transaction(requires_new: true) do
        GroupService.discard(group: group, actor: actor)
        assert_empty events
      end
      assert_equal [[group, actor]], events
      assert group.reload.discarded?
    end
  end

  test "optional engines receive the UTC hour for their periodic jobs" do
    capture_engine_event("loomio_hourly_tick") do |events|
      travel_to Time.utc(2026, 10, 22, 13) do
        HourlyTaskJob.perform_now
      end
      assert_equal [[13]], events
    end
  end

  private

  def capture_engine_event(name)
    events = []
    listener = ->(*arguments) { events << arguments }
    EventBus.listen(name, &listener)
    yield events
  ensure
    EventBus.deafen(name, &listener)
  end
end
