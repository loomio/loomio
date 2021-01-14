class API::B1::MembershipsController < API::B1::BaseController
  def index
    raise CanCan::AccessDenied unless current_webhook.permissions.include?('read_memberships')
    instantiate_collection
    respond_with_collection
  end

  def accessible_records
    Membership.where(group_id: current_webhook.group_id)
  end
end
