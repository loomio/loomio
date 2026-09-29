require 'test_helper'

class NullGroupTest < ActiveSupport::TestCase
  test "implements membership lookup for direct topics" do
    group = topics(:direct_topic).group

    assert_instance_of NullGroup, group
    assert_nil group.membership_for(users(:admin))
    assert_empty group.members
    assert_empty group.admins
    assert_empty group.memberships
    assert_equal false, group.present?
    assert_nil group.presence
  end

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
