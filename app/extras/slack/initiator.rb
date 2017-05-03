class Slack::Initiator
  include PrettyUrlHelper

  def initialize(user_id:, team_id:, type:, title:, channel_id:, channel_name:)
    @identity     = Identities::Slack.find_by(identity_type: :slack, uid: user_id)
    @team_id      = team_id
    @params       = default_url_options.merge({
      type:         type,
      title:        title,
      community_id: community_id(channel_id, channel_name)
    })
  end

  def initiate!
    if bad_identity?
      { error: :bad_identity }
    elsif bad_type?
      { error: :bad_type }
    else
      { url: new_poll_url(@params) }
    end
  end

  private

  def community_id(channel_id, channel_name)
    @identity.communities.find_or_initialize_by(identifier: channel_id, community_type: :slack).tap do |community|
      community.custom_fields['slack_channel_name'] = channel_name
    end.tap(&:save).id unless bad_identity?
  end

  def bad_identity?
    @identity.blank? || @identity.slack_team_id != @team_id
  end

  def bad_type?
    !Poll::TEMPLATES.include?(@params[:type])
  end
end
