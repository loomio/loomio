class ::Slack::Participator
  include Routing

  def initialize(params)
    @domain   = params.dig('team', 'domain')
    @team_id  = params.dig('team', 'id')
    @channel  = params.dig('channel', 'id')
    @poll     = Poll.find_by(id: params['callback_id'])
    @choice   = params.dig('actions', 0, 'name')
    @actor    = Identities::Base.with_user.slack.find_by(uid: params.dig('user', 'id'))&.user
  end

  def participate
    return poll_not_found      unless @poll.present?
    return poll_closed         unless @poll.active?
    return actor_not_found     unless @actor.present?
    return stance_not_valid    unless perform_stance_creation!

    stance_created
  end

  private

  def poll_not_found
    ::Slack::Ephemeral::PollNotFoundSerializer.new({}, root: false).as_json
  end

  def poll_closed
    ::Slack::Ephemeral::PollClosedSerializer.new(@poll, root: false).as_json
  end

  def actor_not_found
    back_to = slack_authorized_url(slack: [@domain, @channel].join('-'))
    ::Slack::Ephemeral::UserNotFoundSerializer.new(slack_oauth_url(back_to: back_to, team: @team_id), root: false).as_json
  end

  def stance_created
    ::Slack::Ephemeral::StanceCreatedSerializer.new(@stance, root: false).as_json
  end

  def stance_not_valid
    ::Slack::Ephemeral::StanceNotValidSerializer.new(@poll, root: false).as_json
  end

  def perform_stance_creation!
    @poll.group.add_member!(@actor)
    @stance = StanceService.create(actor: @actor, stance: Stance.new(poll: @poll, choice: @choice))
  rescue CanCan::AccessDenied
    nil
  end
end
