require "test_helper"
require_relative "support"

class Hocuspocus::AwarenessTest < ActiveSupport::TestCase
  setup { @awareness = Hocuspocus::Awareness.new }

  test "adds, updates and removes client states by clock" do
    assert_equal [[7], [], []], @awareness.apply(update(7, 1, { "name" => "A" }))
    assert_equal [[], [7], []], @awareness.apply(update(7, 2, { "name" => "B" }))
    assert_equal [[], [], []], @awareness.apply(update(7, 1, { "name" => "stale" }))
    # A removal at the current clock wins.
    assert_equal [[], [], [7]], @awareness.apply(update(7, 2, nil))
    refute @awareness.states?
  end

  test "removing a client keeps its clock so peers accept the removal" do
    @awareness.apply(update(7, 3, { "name" => "A" }))
    assert_equal [7], @awareness.remove([7, 8])

    peer = Hocuspocus::Awareness.new
    peer.apply(update(7, 3, { "name" => "A" }))
    assert_equal [[], [], [7]], peer.apply(@awareness.encode([7]))
  end

  test "expires states that have not been renewed" do
    @awareness.apply(update(7, 1, {}), now: 0)
    assert_empty @awareness.outdated_client_ids(now: 29)
    assert_equal [7], @awareness.outdated_client_ids(now: 30)
  end

  test "rejects states that are not JSON" do
    encoder = Hocuspocus::Lib0::Encoder.new
    encoder.write_var_uint(1).write_var_uint(7).write_var_uint(1).write_var_string("{nope")
    assert_raises(Hocuspocus::Lib0::DecodeError) { @awareness.apply(encoder.to_s) }
  end

  private

  def update(client, clock, state)
    encoder = Hocuspocus::Lib0::Encoder.new
    encoder.write_var_uint(1).write_var_uint(client).write_var_uint(clock).write_var_string(JSON.generate(state))
    encoder.to_s
  end
end
