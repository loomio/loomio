class API::SamlProvidersController < API::RestfulController
  def index
    if group = find_group
      saml_provider = SamlProvider.find_by!(group_id: group.id)
      render json: { saml_provider_id:  saml_provider.id, idp_metadata_url: saml_provider.idp_metadata_url }
    else
      render json: {}, status: 404
    end
  end

  def create
    group = load_and_authorize(:group, :set_saml_provider)

    # this will raise 404 if the metadata url is incorrect
    OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(params[:idp_metadata_url])

    SamlProvider.create(group: group, idp_metadata_url: params[:idp_metadata_url])
    group.memberships.update_all(saml_session_expires_at: nil)
    render json: { success: :ok }
  end

  def destroy
    group = load_and_authorize(:group, :set_saml_provider)
    SamlProvider.where(group: group).destroy_all
    render json: { success: :ok }
  end

  private
  def find_group
    if params[:group_id]
      ModelLocator.new(:formal_group, id: params[:group_id]).locate.parent_or_self
    elsif params[:discussion_id]
      ModelLocator.new(:discussion, id: params[:discussion_id]).locate.group.parent_or_self
    end
  end
end
