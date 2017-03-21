class API::CommunitiesController < API::RestfulController

  private

  def accessible_records
    (load_and_authorize(:poll, optional: true) || current_user).communities
  end

  def resource_class
    Communities::Base
  end
end
