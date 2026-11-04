require "test_helper"
require_relative "support"

class Hocuspocus::DocumentTest < ActiveSupport::TestCase
  include HocuspocusTestSupport

  setup do
    @scenario = VECTORS["scenarios"].find { |scenario| scenario["name"] == "five clients without gc" }
    @document = Hocuspocus::Document.new("doc")
  end

  test "holds the same content as Yjs after updates arrive in any order" do
    @scenario["shuffled"].each { |update| @document.apply_update(vector_bytes(update)) }

    expected = Hocuspocus::Yjs.parse_update(vector_bytes(@scenario["merged"]))
    actual = Hocuspocus::Yjs.parse_update(@document.state)
    assert_equal normalize(expected), normalize(actual)
    assert_equal vector_bytes(@scenario["state_vector"]), @document.state_vector
  end

  test "ignores updates it already holds" do
    first = vector_bytes(@scenario["updates"].first)
    assert @document.apply_update(first)
    assert_nil @document.apply_update(first)
  end

  private

  # Compares content regardless of how structs were split into runs.
  def normalize((structs, deletes))
    [structs, deletes].map { |ranges| ranges.transform_values { |list| Hocuspocus::Yjs::DeleteSet.sort_and_merge(list) }.sort.to_h }
  end
end
