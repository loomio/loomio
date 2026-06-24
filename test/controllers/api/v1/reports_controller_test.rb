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
end
