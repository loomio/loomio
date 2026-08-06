require "test_helper"

class Api::V1::ReportsControllerTest < ActionController::TestCase
  class EmptyReport
    def intervals
      []
    end

    def users
      []
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

  test "instance admins can report on the whole server" do
    json, report_options = request_report(users(:admin))

    assert_equal ['all'], json.fetch('group_scope_options').pluck('value')
    assert_equal 'all', json.fetch('group_scope')
    assert_empty json.fetch('group_ids')
    assert report_options.fetch(:all_groups)
    assert_nil report_options.fetch(:group_ids)
  end

  test "instance admins also have parent group scopes" do
    parent = groups(:group)
    secret_subgroup = create_subgroup(parent, 'secret')
    json, report_options = request_report(users(:admin), group_id: parent.id)

    assert_equal ['all', 'organisation', "group:#{parent.id}"], json.fetch('group_scope_options').pluck('value')
    assert_equal 'organisation', json.fetch('group_scope')
    assert_includes report_options.fetch(:group_ids), parent.id
    assert_includes report_options.fetch(:group_ids), groups(:subgroup).id
    refute_includes report_options.fetch(:group_ids), secret_subgroup.id
    refute report_options.fetch(:all_groups)
  end

  test "parent group admins can report on accessible subgroups" do
    parent = groups(:group)
    admin = users(:user)
    memberships(:user_membership).update!(admin: true)
    closed_subgroup = create_subgroup(parent, 'closed')
    open_subgroup = create_subgroup(parent, 'open')
    secret_subgroup = create_subgroup(parent, 'secret')
    joined_secret_subgroup = create_subgroup(parent, 'secret')
    joined_secret_subgroup.add_member!(admin, inviter: admin)

    json, report_options = request_report(admin, group_id: parent.id)
    group_ids = report_options.fetch(:group_ids)

    assert_equal ['organisation', "group:#{parent.id}"], json.fetch('group_scope_options').pluck('value')
    assert_equal 'organisation', json.fetch('group_scope')
    assert_includes group_ids, parent.id
    assert_includes group_ids, closed_subgroup.id
    assert_includes group_ids, open_subgroup.id
    assert_includes group_ids, joined_secret_subgroup.id
    refute_includes group_ids, secret_subgroup.id
  end

  test "parent group admins can report on the parent group alone" do
    parent = groups(:group)
    admin = users(:user)
    memberships(:user_membership).update!(admin: true)

    json, report_options = request_report(admin, group_id: parent.id, group_scope: "group:#{parent.id}")

    assert_equal "group:#{parent.id}", json.fetch('group_scope')
    assert_equal [parent.id], report_options.fetch(:group_ids)
  end

  test "ordinary members can only report on the requested group" do
    parent = groups(:group)
    member = users(:member)

    json, report_options = request_report(
      member,
      group_id: parent.id,
      group_scope: "group:#{groups(:alien_group).id}"
    )

    assert_equal ["group:#{parent.id}"], json.fetch('group_scope_options').pluck('value')
    assert_equal "group:#{parent.id}", json.fetch('group_scope')
    assert_equal [parent.id], report_options.fetch(:group_ids)
  end

  test "ordinary members can select groups they belong to within the organisation" do
    parent = groups(:group)
    subgroup = groups(:subgroup)
    member = users(:user)

    json, report_options = request_report(
      member,
      group_id: parent.id,
      group_scope: "group:#{subgroup.id}"
    )

    assert_equal ["group:#{parent.id}", "group:#{subgroup.id}"], json.fetch('group_scope_options').pluck('value')
    assert_equal "group:#{subgroup.id}", json.fetch('group_scope')
    assert_equal [subgroup.id], report_options.fetch(:group_ids)
  end

  test "subgroup reports only include the requested subgroup" do
    subgroup = groups(:subgroup)
    user = users(:user)

    json, report_options = request_report(user, group_id: subgroup.id, group_scope: 'organisation')

    assert_equal ["group:#{subgroup.id}"], json.fetch('group_scope_options').pluck('value')
    assert_equal "group:#{subgroup.id}", json.fetch('group_scope')
    assert_equal [subgroup.id], report_options.fetch(:group_ids)
  end

  test "non-members cannot report on a group" do
    sign_in users(:alien)

    get :index, params: {group_id: groups(:group).id}

    assert_response :forbidden
  end

  private

  def request_report(user, params = {})
    report_options = nil
    build_report = lambda do |**options|
      report_options = options
      EmptyReport.new
    end
    sign_in user
    ReportService.stub(:new, build_report) do
      get :index, params: params
    end
    assert_response :success
    [JSON.parse(response.body), report_options]
  end

  def create_subgroup(parent, group_privacy)
    Group.create!(
      name: "Report subgroup #{SecureRandom.hex(4)}",
      parent: parent,
      group_privacy: group_privacy
    )
  end
end
