require 'test_helper'

class EventBusTest < ActiveSupport::TestCase
  setup do
    @saved_listeners = EventBus.class_variable_get(:@@listeners) rescue nil
    EventBus.clear
  end

  teardown do
    if @saved_listeners
      EventBus.class_variable_set(:@@listeners, @saved_listeners)
    else
      EventBus.clear
    end
  end

  test "activates a listener with an event name" do
    called = false
    EventBus.listen('my_event') { called = true }
    EventBus.broadcast('my_event')
    assert called
  end

  test "activates a listener with params" do
    received_param = nil
    EventBus.listen('my_event') { |param| received_param = param }
    EventBus.broadcast('my_event', :test_value)
    assert_equal :test_value, received_param
  end

  test "does not activate events with a different event name" do
    called = false
    EventBus.listen('my_event') { called = true }
    EventBus.broadcast('my_other_event')
    refute called
  end

  test "can accept multiple event names for listen" do
    call_count = 0
    EventBus.listen('my_event', 'my_other_event') { call_count += 1 }
    EventBus.broadcast('my_event')
    EventBus.broadcast('my_other_event')
    assert_equal 2, call_count
  end

  test "deafen silences listeners with an event name" do
    called = false
    handler = proc { called = true }
    EventBus.listen('my_event', &handler)
    EventBus.deafen('my_event', &handler)
    EventBus.broadcast('my_event')
    refute called
  end

  test "deafen does not silence other events" do
    called = false
    handler = proc { called = true }
    EventBus.listen('my_event', &handler)
    EventBus.deafen('my_other_event', &handler)
    EventBus.broadcast('my_event')
    assert called
  end

  test "deafen can accept multiple event names" do
    called = false
    handler = proc { called = true }
    EventBus.listen('my_event', &handler)
    EventBus.listen('my_other_event', &handler)
    EventBus.deafen('my_event', 'my_other_event', &handler)
    EventBus.broadcast('my_event')
    EventBus.broadcast('my_other_event')
    refute called
  end

  test "clear empties the listeners" do
    called = false
    EventBus.listen('my_event') { called = true }
    EventBus.clear
    EventBus.broadcast('my_event')
    refute called
  end
end
