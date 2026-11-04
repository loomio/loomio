require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::UserTest < ActiveSupport::TestCase
  test "account visibility requires a signed-in viewer and an active target" do
    target = users(:member_normal)
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]
    actors.each { |actor| assert_equal actor.is_logged_in?, actor.can?(:show, target), actor.id.to_s }

    target.update!(deactivated_at: Time.current)
    actors.each { |actor| assert_not actor.can?(:show, target), actor.id.to_s }
  end

  test "account preferences and notification access belong to the account owner" do
    target = users(:member_normal)
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]
    actors.each do |actor|
      %i[update see_notifications_for subscribe_to].each do |action|
        assert_equal actor.id == target.id, actor.can?(action, target), "#{actor.id}: #{action}"
      end
    end
  end

  test "only the owner or an instance admin can deactivate or redact an eligible account" do
    target = users(:member_normal)
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]
    actors.each do |actor|
      expected = actor.id == target.id || actor.is_admin?
      assert_equal expected, actor.can?(:deactivate, target), actor.id.to_s
      assert_equal expected, actor.can?(:redact, target), actor.id.to_s
    end

    target.update_columns(deactivated_at: Time.current, email: nil)
    actors.each do |actor|
      assert_not actor.can?(:deactivate, target), actor.id.to_s
      assert_not actor.can?(:redact, target), actor.id.to_s
    end
  end
end
