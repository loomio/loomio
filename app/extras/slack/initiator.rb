class Slack::Initiator
  include PrettyUrlHelper

  def initialize(uid:, token:, type:, team_id:)
    @identity = Identities::Slack.find_by(identity_type: :slack, uid: uid)
    @team_id  = team_id
    @params   = { type: text, title: title }
  end

  def initiate!
     new_poll_url(@params, default_url_options) if can_initiate?
   end

  private

  def can_initiate?
    @identity.present? && @identity.slack_team_id == @team_id
  end
end
