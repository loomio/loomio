class Identities::FacebookController < Identities::BaseController

  def groups
    if identity.present?
      render json: identity.fetch_admin_groups
    else
      render json: { error: "Not connected to facebook!" }, status: :bad_request
    end
  end

  private

  def complete_identity(identity)
    identity.fetch_user_info
    identity.fetch_user_avatar
  end

  def oauth_url
    "https://www.facebook.com/v2.8/dialog/oauth"
  end

  def oauth_params
    super.merge(app_id: client.key)
  end
end
