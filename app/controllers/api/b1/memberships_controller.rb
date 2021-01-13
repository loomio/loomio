class API::B1::MembershipsController < API::B1::BaseController
  def index
    instantiate_collection
    respond_with_collection
  end

  def accessible_records
    Membership.where(group_id: current_webhook.group_id)
  end
end
