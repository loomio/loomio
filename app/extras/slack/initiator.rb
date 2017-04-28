class Slack::Initiator
  include PrettyUrlHelper

  def initialize(uid:, team_id:, type:, title:)
    @identity = Identities::Slack.find_by(identity_type: :slack, uid: uid)
    @team_id  = team_id
    @params   = { type: type, title: title }
  end

  def initiate!
    if bad_identity?
      { error: :bad_identity }
    elsif bad_type?
      { error: :bad_type }
    else
      { url: new_poll_url(default_url_options.merge(@params)) }
    end
  end

  private

  def bad_identity?
    @identity.blank? || @identity.slack_team_id != @team_id
  end

  def bad_type?
    !Poll::TEMPLATES.include?(@params[:type])
  end
end
