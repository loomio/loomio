module Identities::Slack::Participate
  def participate
    render json: respond_with_stance      ||
                 respond_with_poll_closed ||
                 respond_with_invitation  ||
                 respond_with_participate_unauthorized
  end

  private

  def respond_with_stance
    return unless can_participate?
    ::Slack::Ephemeral::StanceCreatedSerializer.new(StanceService.create(
      stance: participate_stance,
      actor: participate_participant
    ), root: false).as_json
  end

  def respond_with_poll_closed
    return unless !participate_poll.active?
    ::Slack::Ephemeral::PollClosedSerializer.new(participate_poll, root: false).as_json
  end

  def respond_with_invitation
    return unless participate_invitation&.slack_team_id.present?
    ::Slack::Ephemeral::GroupInvitationSerializer.new(participate_invitation, scope: {
      back_to: poll_url(participate_poll),
      uid:     participate_payload.dig('user', 'id')
    }, root: false).as_json
  end

  def respond_with_participate_unauthorized
      ::Slack::Ephemeral::RequestAuthorizationSerializer.new({
        url: request_authorization_url(participate_payload['team'])
      }, root: false).as_json
  end

  def participate_invitation
    @participate_invitation ||= participate_poll&.group&.shareable_invitation
  end

  def participate_poll
    @participate_poll ||= Poll.find_by(id: participate_payload['callback_id'])
  end

  def can_participate?
    participate_participant&.can? :create, participate_stance
  end

  def participate_stance
    @participate_stance ||= Stance.new(
      poll:   participate_poll,
      choice: participate_payload.dig('actions', 0, 'name')
    )
  end

  def participate_participant
    byebug
    @participate_participant ||= Identities::Base
      .where(identity_type: :slack, uid: participate_payload.dig('user', 'id'))
      .first&.user
  end

  def participate_payload
    @participate_payload ||= JSON.parse(params.require(:payload))
  end
end
