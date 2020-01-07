class API::SamlProvidersController < API::RestfulController
  def create
    group = load_and_authorize(:group, :set_saml_provider)
    SamlProvider.create(group: group, idp_metadata_url: params[:idp_metadata_url])
    render json: { success: :ok }
  end
end
