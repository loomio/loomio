class API::GroupIdentitiesController < API::RestfulController
  private

  def instantiate_resource
    super.tap do |resource|
      resource.identity = resource.group.identity_for(resource_params[:identity_type])&.identity ||
                          current_user.identity_for(resource_params[:identity_type])
    end
  end
end
