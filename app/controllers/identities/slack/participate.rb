module Identities::Slack::Participate
  def participate
    render json: respond_with_poll_closed ||
                 respond_with_stance      ||
                 respond_with_participate_unauthorized
  end

  private

  def respond_with_poll_closed
    return unless !participate_poll.active?
    ::Slack::Ephemeral::PollClosedSerializer.new(participate_poll, root: false).as_json
  end

  def respond_with_stance
    return unless participate_poll&.group&.add_member!(participate_identity&.user)
    ::Slack::Ephemeral::StanceCreatedSerializer.new(participate_stance_event, root: false).as_json
  end

  def respond_with_participate_unauthorized
    ::Slack::Ephemeral::RequestAuthorizationSerializer.new({
      url: request_authorization_url(participate_payload['team'])
    }, root: false).as_json
  end

  def participate_stance_event
    @participant_stance_event ||= StanceService.create(
      stance: participate_stance,
      actor:  participate_identity.user
    )
  end

  def participate_stance
    @participate_stance ||= Stance.new(
    poll:   participate_poll,
    choice: participate_payload.dig('actions', 0, 'name')
    )
  end

  def participate_poll
    @participate_poll ||= Poll.find_by(id: participate_payload['callback_id'])
  end


  def participate_identity
    @participate_participant ||= Identities::Base.find_by(
      identity_type: :slack,
      uid:           participate_payload.dig('user', 'id')
    )
  end

  def participate_payload
    @participate_payload ||= JSON.parse(params.require(:payload))
  end
end
