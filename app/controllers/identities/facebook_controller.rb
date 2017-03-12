class Identities::FacebookController < ApplicationController
  def create
    if current_user.identities.push build_facebook_identity
      redirect_to dashboard_path
    else
      render json: { error: "Could not connect to facebook!" }, status: :bad_request
    end
  end

  def destroy
    if identity = current_user.facebook_identity
      identity.destroy
      redirect_to dashboard_path
    else
      render json: { error: "Not connected to facebook!" }, status: :bad_request
    end
  end

  def groups
    if identity = current_user.facebook_identity
      render json: identity.fetch_admin_groups
    else
      render json: { error: "Not connected to facebook!" }, status: :bad_request
    end
  end

  private

  def build_facebook_identity
    Identities::Facebook.new(access_token: fetch_access_token).tap(&:fetch_user_id)
  end

  def fetch_access_token
    @access_token ||= client.post("oauth/access_token", { code: params[:code], redirect_uri: facebook_authorize_url }) { |response| response['access_token'] }
  end

  def client
    @client ||= Clients::Facebook.new(key: ENV['FACEBOOK_APP_KEY'], secret: ENV['FACEBOOK_APP_SECRET'])
  end

end
