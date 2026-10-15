require 'test_helper'

class NullGroupTest < ActiveSupport::TestCase
  test "direct topics have an active subscription without member or thread limits" do
    group = topics(:direct_topic).group
    subscription = group.subscription

    assert_equal true, group.subscription_active?
    assert_equal true, subscription.is_active?
    assert_equal true, subscription.allow_subgroups
    assert_equal 0, subscription.members_count
    assert_nil subscription.max_members
    assert_nil subscription.max_threads
    assert_nil subscription.plan
    assert_nil subscription.state
    assert_nil subscription.renews_at
    assert_nil subscription.expires_at
  end

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

  test "count rebuilds require a real group" do
    group = topics(:direct_topic).group

    assert_raises(ArgumentError) { group.update_membership_counts }
    assert_raises(ArgumentError) { group.update_content_counts }
  end

  test "self or parent image urls can be called with explicit size" do
    group = NullGroup.new

    assert_nil group.self_or_parent_logo_url(128)
    assert_nil group.self_or_parent_cover_url(300)
  end
end
