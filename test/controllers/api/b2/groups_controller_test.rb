require "test_helper"
require_relative "../../../support/access_volume_matrix"

class Api::B2::GroupsControllerTest < ActionController::TestCase
  setup do
    @user = users(:admin)
    @request.headers["Authorization"] = "Bearer #{@user.api_key}"
  end

  test "individual group reads enforce visibility and active API credentials" do
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin)]

    %i[group public_group parent_join_subgroup].each do |group_name|
      group = groups(group_name)
      actors.each do |actor|
        @request.headers["Authorization"] = "Bearer #{actor.api_key}"

        get :show, params: { id: group.id }

        if actor.active? && actor.can?(:show, group)
          assert_response :success
          assert_equal [group.id], response.parsed_body.fetch("groups").pluck("id")
        else
          assert_response :forbidden
          refute response.parsed_body.key?("groups"), "#{group_name}, actor=#{actor.id}"
        end
      end
    end

    @request.headers["Authorization"] = nil
    get :show, params: { id: groups(:public_group).id }
    assert_response :forbidden
    refute response.parsed_body.key?("groups")
  end

  test "pages current memberships with an exact total and stable group order" do
    expected_ids = groups(:group, :subgroup, :subgroup_other).map(&:id).sort
    actual_ids = expected_ids.each_index.flat_map do |offset|
      get :index, params: { limit: 1, offset: offset, compact: 1 }

      assert_response :success
      assert_equal expected_ids.length, response.parsed_body.dig("meta", "total")
      response.parsed_body.fetch("groups").pluck("id")
    end
    assert_equal expected_ids, actual_ids

    get :index, params: { limit: 1, offset: expected_ids.length }

    assert_response :success
    assert_empty response.parsed_body.fetch("groups")
    assert_equal expected_ids.length, response.parsed_body.dig("meta", "total")
  end

  test "bounds default and requested group pages without losing the total" do
    501.times do |index|
      group = Group.create!(name: "API page group #{index}", creator: @user)
      group.add_member!(@user)
    end
    expected_ids = @user.groups.order(:id).pluck(:id)

    [[{}, 50], [{ limit: 100 }, 100], [{ limit: 1000 }, 500], [{ limit: 1000, offset: 500 }, 500]].each do |params, page_size|
      get :index, params: params.merge(compact: 1)

      assert_response :success
      assert_equal expected_ids.drop(params.fetch(:offset, 0)).first(page_size), response.parsed_body.fetch("groups").pluck("id")
      assert_equal expected_ids.length, response.parsed_body.dig("meta", "total")
    end
  end

  test "pagination does not expand group discovery beyond current memberships" do
    expected = {
      member: [groups(:group).id],
      guest_normal: [],
      former_member_loud: [],
      server_admin: [],
      alien: [groups(:alien_group).id]
    }

    expected.each do |role, ids|
      @request.headers["Authorization"] = "Bearer #{users(role).api_key}"
      get :index, params: { limit: 1, offset: 0, compact: 1 }

      assert_response :success
      assert_equal ids, response.parsed_body.fetch("groups").pluck("id"), role.to_s
      assert_equal ids.length, response.parsed_body.dig("meta", "total"), role.to_s
    end
  end

  test "paged groups reject missing and inactive API credentials" do
    [nil, "Bearer #{users(:inactive_member_loud).api_key}"].each do |authorization|
      @request.headers["Authorization"] = authorization
      get :index, params: { limit: 1, offset: 1 }

      assert_response :forbidden
      refute response.parsed_body.key?("groups")
      refute response.parsed_body.key?("meta")
    end
  end
end
