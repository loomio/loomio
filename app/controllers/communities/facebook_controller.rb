class Communities::FacebookController < ApplicationController

  def create
    current_user.facebook_community ||= Communities::Facebook.new(facebook_access_token: fetch_access_token, facebook_user_id: fetch_user_id)
    if current_user.save
      redirect_to dashboard_path
    else
      render json: { error: "Could not connect to facebook!" }, status: :bad_request
    end
  end

  def destroy
    if community
      community.destroy
      redirect_to dashboard_path
    else
      render json: { error: "Not connected to facebook!" }, status: :bad_request
    end
  end

  def groups
    if community
      render json: fetch_groups
    else
      render json: { error: "Not connected to facebook!" }, status: :bad_request
    end
  end

  private

  def fetch_access_token
    @access_token ||= client.post("oauth/access_token", { code: params[:code], redirect_uri: facebook_authorize_url }) { |response| response['access_token'] }
  end

  def fetch_user_id
    @user_id ||= client.get("me", { access_token: fetch_access_token }) { |response| response['id'] }
  end

  def fetch_groups
    @group_ids ||= client.get("#{community.facebook_user_id}/groups") { |response| response }
  end

  def client
    @client ||= Clients::Facebook.new(ENV['FACEBOOK_APP_KEY'], ENV['FACEBOOK_APP_SECRET'], community&.facebook_access_token)
  end

  def community
    @community ||= current_user.facebook_community
  end

end
