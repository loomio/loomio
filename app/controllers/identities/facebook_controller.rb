class Identities::FacebookController < Identities::BaseController

  def groups
    if identity.present?
      render json: identity.fetch_admin_groups
    else
      render json: { error: "Not connected to facebook!" }, status: :bad_request
    end
  end

  private

  def identity
    @identity ||= current_user.facebook_identity
  end

  def build_identity
    @build_identity ||= Identities::Facebook.new(access_token: fetch_access_token).tap(&:fetch_user_id)
  end

  def fetch_access_token
    @access_token ||= client.post("oauth/access_token", code: params[:code], redirect_uri: redirect_uri) { |response| response['access_token'] }
  end

  def oauth_url
    "https://www.facebook.com/v2.8/dialog/oauth"
  end

  def oauth_params
    super.merge(app_id: client.key)
  end
end
