module Identities::Slack::Participate
  def participate
    render json: respond_with_stance ||
                 respond_with_poll_closed ||
                 respond_with_invitation ||
                 respond_with_unauthorized(participate_payload['team'])
  end

  private

  def respond_with_stance
    return unless event = ::Slack::Participator.new(participate_params).participate!
    ::Slack::Ephemeral::StanceCreatedSerializer.new(event, root: false).as_json
  end

  def respond_with_poll_closed
    return unless !participate_poll.active?
    ::Slack::Ephemeral::PollClosedSerializer.new(participate_poll, root: false).as_json
  end

  def respond_with_invitation
    return unless participate_invitation&.slack_team_id.present?
    ::Slack::Ephemeral::GroupInvitationSerializer.new(participate_invitation, scope: {
      back_to: poll_url(participate_poll),
      uid: participate_params[:uid]
    }, root: false).as_json
  end

  def participate_invitation
    @participate_invitation ||= participate_poll&.group&.shareable_invitation
  end

  def participate_params
    @participate_params ||= {
      uid:              participate_payload.dig('user', 'id'),
      poll_id:          participate_payload.dig('callback_id'),
      choice:           participate_payload.dig('actions', 0, 'name')
    }
  end

  def participate_payload
    @participate_payload ||= JSON.parse(params.require(:payload))
  end

  def participate_poll
    @participate_poll ||= Poll.find_by(id: participate_params[:poll_id])
  end
end
