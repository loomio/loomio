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
    participate_poll&.group&.add_member!(participate_identity&.user)
    return unless participate_stance.present?
    ::Slack::Ephemeral::StanceCreatedSerializer.new(participate_stance, root: false).as_json
  end

  def respond_with_participate_unauthorized
    ::Slack::Ephemeral::RequestAuthorizationSerializer.new(request_authorization_url(participate_payload['team']), root: false).as_json
  end

  def participate_stance
    @participant_stance ||= StanceService.create(
      stance: Stance.new(poll: participate_poll, choice: participate_payload.dig('actions', 0, 'name')),
      actor:  participate_identity.user
    )
  rescue CanCan::AccessDenied
    nil
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
