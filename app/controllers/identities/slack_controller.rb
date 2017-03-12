class Identities::SlackController < ApplicationController
  def create
    if current_user.identities.push build_slack_identity
      redirect_to dashboard_path
    else
      render json: { error: "Could not connect to slack!" }, status: :bad_request
    end
  end

  def destroy
    if identity = current_user.slack_identity
      identity.destroy
      redirect_to dashboard_path
    else
      render json: { error: "Not connected to slack!" }, status: :bad_request
    end
  end

  def channels
    if identity = current_user.slack_identity
      render json: identity.fetch_channels
    else
      render json: { error: "Not connected to slack!" }, status: :bad_request
    end
  end

  private

  def build_slack_identity
    Identities::Slack.new(client.get("oauth.access", { code: params[:code], redirect_uri: slack_authorize_url }) do |response|
      {
        access_token:  response['access_token'],
        slack_team_id: response['team_id'],
        slack_user_id: response['user_id']
      }
    end)
  end

  def client
    @client ||= Clients::Slack.new(key: ENV['SLACK_APP_KEY'], secret: ENV['SLACK_APP_SECRET'])
  end
end
