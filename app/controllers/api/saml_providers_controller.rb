class API::SamlProvidersController < API::RestfulController
  def index
    saml_provider = SamlProvider.find_by!(group_id: params[:group_id])
        render json: { saml_provider_id:  saml_provider.id,
                       idp_metadata_url: saml_provider.idp_metadata_url,
                       sp_metadata_url: metadata_saml_provider_url(saml_provider)
                      }
  end

  def create
    group = load_and_authorize(:group, :set_saml_provider)

    # this will raise 404 if the metadata url is incorrect
    OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(params[:idp_metadata_url])

    SamlProvider.create(group: group, idp_metadata_url: params[:idp_metadata_url])
    group.memberships.update_all(saml_session_expires_at: Time.current)
    render json: { success: :ok }
  end

  def destroy
    group = load_and_authorize(:group, :set_saml_provider)
    SamlProvider.where(group: group).destroy_all
    group.memberships.update_all(saml_session_expires_at: nil)
    render json: { success: :ok }
  end
end
