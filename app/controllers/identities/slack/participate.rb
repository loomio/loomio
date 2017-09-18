module Identities::Slack::Participate
  def participate
    render json: participate_json
  end

  private

  def participate_json
    return poll_not_found      unless participate_poll.present?
    return poll_closed         unless participate_poll.active?
    return user_not_found      unless participate_user.present?

    participate_poll.group.add_member!(participate_user)
    return stance_not_valid    unless participate_stance.present?

    stance_created
  end

  def poll_not_found
    ::Slack::Ephemeral::PollNotFoundSerializer.new({}, root: false).as_json
  end

  def poll_closed
    ::Slack::Ephemeral::PollClosedSerializer.new(participate_poll, root: false).as_json
  end

  def user_not_found
    ::Slack::Ephemeral::UserNotFoundSerializer.new(request_authorization_url(participate_payload['team']), root: false).as_json
  end

  def stance_not_valid
    ::Slack::Ephemeral::StanceNotValidSerializer.new(participate_poll, root: false).as_json
  end

  def stance_created
    ::Slack::Ephemeral::StanceCreatedSerializer.new(participate_stance, root: false).as_json
  end

  def participate_stance
    @participant_stance ||= StanceService.create(
      stance: Stance.new(poll: participate_poll, choice: participate_payload.dig('actions', 0, 'name')),
      actor:  participate_user
    )
  rescue CanCan::AccessDenied
    nil
  end

  def participate_poll
    @participate_poll ||= Poll.find_by(id: participate_payload['callback_id'])
  end

  def participate_user
    @participate_user ||= Identities::Base.with_user.find_by(
      identity_type: :slack,
      uid:           participate_payload.dig('user', 'id')
    )&.user
  end

  def participate_ensure_token
    head :bad_request unless participate_payload['token'] == ENV['SLACK_VERIFICATION_TOKEN']
  end

  def participate_payload
    @participate_payload ||= JSON.parse(params.require(:payload))
  end
end
