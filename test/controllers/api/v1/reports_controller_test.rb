require "test_helper"

class Api::V1::ReportsControllerTest < ActionController::TestCase
  class EmptyReport
    def intervals
      []
    end

    def users
      []
    end

    def delegate_user_ids
      Set.new
    end

    def countries
      []
    end

    def method_missing(name, *args)
      return {} if name.to_s.end_with?('_per_interval', '_per_user', '_per_country')
      return {} if %i[tag_counts tag_counts_per_interval tag_threads_per_user tag_threads_authored_per_user users_per_country].include?(name)
      return [] if name == :tag_names
      return 0 if name.to_s.end_with?('_count')

      super
    end

    def respond_to_missing?(name, include_private = false)
      name.to_s.end_with?('_per_interval', '_per_user', '_per_country', '_count') ||
        %i[tag_names tag_counts tag_counts_per_interval tag_threads_per_user tag_threads_authored_per_user users_per_country].include?(name) ||
        super
    end
  end

  test "custom group selector includes memberships and subgroups, not every admin-visible group" do
    admin = users(:admin)
    group = groups(:group)
    subgroup = groups(:subgroup)
    alien_group = groups(:alien_group)
    sign_in admin

    ReportService.stub(:new, EmptyReport.new) do
      get :index, params: {group_scope: 'custom', group_ids: group.id.to_s}
    end

    assert_response :success
    group_ids = JSON.parse(response.body)['all_groups'].map { |group| group['id'] }

    assert_includes group_ids, 0
    assert_includes group_ids, group.id
    assert_includes group_ids, subgroup.id
    refute_includes group_ids, alien_group.id
  end

  test "my reports exclude subgroups hidden from parent group members" do
    user = users(:user)
    parent = groups(:group)
    victim = User.create!(
      name: "Hidden subgroup member",
      email: "hidden-subgroup-member@example.com",
      email_verified: true,
      username: "hiddensubgroupmember",
      country: "NZ"
    )
    hidden_subgroup = Group.create!(
      name: "Hidden reports subgroup",
      handle: "testgroup-hidden-reports-subgroup",
      parent: parent,
      is_visible_to_public: false,
      is_visible_to_parent_members: false
    )
    Membership.create!(group: hidden_subgroup, user: victim, accepted_at: Time.current)
    sign_in user

    get :index, params: {group_scope: "my", section: "users"}

    assert_response :success
    json = JSON.parse(response.body)
    refute_includes json.fetch("all_groups").map { |group| group["id"] }, hidden_subgroup.id
    refute_includes json.fetch("users").map { |record| record["id"] }, victim.id
  end

  test "delegate user rows contain aggregate counts and include inactive delegates" do
    user = users(:user)
    group = groups(:group)
    membership = group.membership_for(user)
    membership.update!(delegate: true)
    sign_in user

    get :index, params: {
      group_scope: "custom",
      group_ids: group.id,
      section: "users",
      member_type: "delegate"
    }

    assert_response :success
    row = JSON.parse(response.body).fetch("users").find { |record| record["id"] == user.id }
    assert_equal true, row.fetch("delegate")
    %w[threads comments polls votes votes_cast votes_issued votes_missed outcomes reactions].each do |field|
      assert_kind_of Integer, row.fetch(field)
    end
    assert_includes [true, false], row.fetch("all_votes_cast")
    assert_empty JSON.parse(response.body).fetch("discussions_per_user").keys - [user.id.to_s]
  end

  test "delegate filter does not expose delegates from an unselected group" do
    user = users(:user)
    group = groups(:group)
    alien_group = groups(:alien_group)
    alien_group.add_member!(user).update!(delegate: true)
    sign_in user

    get :index, params: {
      group_scope: "custom",
      group_ids: group.id,
      section: "users",
      member_type: "delegate"
    }

    assert_response :success
    refute_includes JSON.parse(response.body).fetch("users").map { |record| record["id"] }, user.id
  end
end
