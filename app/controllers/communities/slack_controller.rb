class Communities::SlackController < ApplicationController
  def create
    current_user.slack_community ||= Communities::Slack.new(fetch_slack_info)
    if current_user.save
      redirect_to dashboard_path
    else
      render json: { error: "Could not connect to slack!" }, status: :bad_request
    end
  end

  def destroy
    if community
      community.destroy
      redirect_to dashboard_path
    else
      render json: { error: "Not connected to slack!" }, status: :bad_request
    end
  end

  def channels
    if community
      render json: fetch_channels
    else
      render json: { error: "Not connected to slack!" }, status: :bad_request
    end
  end

  private

  def fetch_slack_info
    @slack_info ||= client.get("oauth.access", { code: params[:code], redirect_uri: slack_authorize_url }) do |response|
      {
        slack_access_token: response['access_token'],
        slack_team_id:      response['team_id'],
        slack_user_id:      response['user_id']
      }
    end
  end

  def fetch_channels
    @channels ||= client.get("channels.list") { |response| response }
  end

  def client
    @client ||= Clients::Slack.new(ENV['SLACK_APP_KEY'], ENV['SLACK_APP_SECRET'], community&.slack_access_token)
  end

  def community
    @community ||= current_user.slack_community
  end
end
