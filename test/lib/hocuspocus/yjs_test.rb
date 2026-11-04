require "test_helper"
require_relative "support"

# The vectors hold Yjs's own results (see generate_yjs_vectors.mjs); the port
# must match them byte for byte.
class Hocuspocus::YjsTest < ActiveSupport::TestCase
  include HocuspocusTestSupport

  Yjs = Hocuspocus::Yjs

  VECTORS["scenarios"].each do |scenario|
    test "merges updates like Yjs: #{scenario["name"]}" do
      decode = ->(list) { list.map { |update| vector_bytes(update) } }
      assert_equal vector_bytes(scenario["merged"]), Yjs.merge_updates(decode[scenario["updates"]])
      assert_equal vector_bytes(scenario["merged_shuffled"]), Yjs.merge_updates(decode[scenario["shuffled"]])
      assert_equal vector_bytes(scenario["merged_partial"]), Yjs.merge_updates(decode[scenario["partial"]])
    end

    test "derives state vectors and diffs like Yjs: #{scenario["name"]}" do
      merged = vector_bytes(scenario["merged"])
      partial = vector_bytes(scenario["merged_partial"])
      peer = vector_bytes(scenario["peer_state_vector"])
      assert_equal vector_bytes(scenario["state_vector"]), Yjs.encode_state_vector_from_update(merged)
      assert_equal vector_bytes(scenario["state_vector_partial"]), Yjs.encode_state_vector_from_update(partial)
      assert_equal vector_bytes(scenario["diff"]), Yjs.diff_update(merged, peer)
      assert_equal vector_bytes(scenario["diff_partial"]), Yjs.diff_update(partial, peer)
    end
  end

  test "measures and splits strings in UTF-16 code units" do
    content = Yjs::ContentString.new("a😀b")
    assert_equal 4, content.length

    assert_equal ["a😀", "b"], Yjs::ContentString.split("a😀b", 3)
    # Splitting a surrogate pair leaves a replacement character on each side.
    assert_equal ["a�", "�b"], Yjs::ContentString.split("a😀b", 2)
  end

  test "rejects truncated updates" do
    merged = vector_bytes(VECTORS["scenarios"].first["merged"])
    assert_raises(Hocuspocus::Lib0::DecodeError) { Yjs.parse_update(merged.byteslice(0, merged.bytesize / 2)) }
  end
end
