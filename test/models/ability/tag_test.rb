require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::TagTest < ActiveSupport::TestCase
  test "tag visibility follows group visibility across the reusable role matrix" do
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]

    %i[group public_group parent_join_subgroup].each do |group_name|
      group = groups(group_name)
      tag = Tag.new(group: group, name: "Visibility")

      actors.each do |actor|
        assert_equal actor.can?(:show, group), actor.can?(:show, tag), "#{group_name}, actor=#{actor.id}"
      end
    end
  end
end
