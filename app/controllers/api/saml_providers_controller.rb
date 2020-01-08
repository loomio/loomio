class API::SamlProvidersController < API::RestfulController
  def index
    if group = find_group
      saml_provider = SamlProvider.find_by!(group_id: group.id)
      render json: { saml_provider_id:  saml_provider.id }
    else
      render json: {}, status: 404
    end
  end

  def create
    group = load_and_authorize(:group, :set_saml_provider)
    SamlProvider.create(group: group, idp_metadata_url: params[:idp_metadata_url])
    render json: { success: :ok }
  end

  private
  def find_group
    if params[:group_id]
      ModelLocator.new(:formal_group, id: params[:group_id]).locate
    elsif params[:discussion_id]
      ModelLocator.new(:discussion, id: params[:discussion_id]).locate.group
    end
  end
end
