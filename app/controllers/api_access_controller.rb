class ApiAccessController < ApplicationController
  before_action :authenticate_user!

  def show
    prevent_caching
    response.headers['Referrer-Policy'] = 'no-referrer'

    groups = current_user.memberships.accepted.includes(:group).filter_map do |membership|
      membership.group unless membership.group.archived_at?
    end.sort_by { |group| [group.name.downcase, group.id] }

    render Views::Profile::ApiAccess.new(
      api_key: current_user.api_key,
      groups: groups
    )
  end
end
