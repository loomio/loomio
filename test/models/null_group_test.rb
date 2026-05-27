require 'test_helper'

class NullGroupTest < ActiveSupport::TestCase
  test "self or parent image urls can be called without explicit size" do
    group = NullGroup.new

    assert_nil group.self_or_parent_logo_url
    assert_nil group.self_or_parent_cover_url
  end

  test "self or parent image urls can be called with explicit size" do
    group = NullGroup.new

    assert_nil group.self_or_parent_logo_url(128)
    assert_nil group.self_or_parent_cover_url(300)
  end
end
