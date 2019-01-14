class API::GroupIdentitiesController < API::RestfulController
  private

  def instantiate_resource
    super.tap do |resource|
      resource.identity = resource.group.identity_for(resource_params[:identity_type])&.identity ||
                          current_user.identity_for(resource_params[:identity_type]) ||
                          generate_webhook_identity
    end
  end

  def generate_webhook_identity
    current_user.identities.build(
      identity_type: resource_params[:identity_type],
      access_token:  resource.webhook_url,
      uid:           resource.webhook_url
    )
  end
end
