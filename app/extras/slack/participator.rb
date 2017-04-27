class Slack::Participator
  def initialize(identifier:, poll_id:, choice:)
    @identity = Identities::Slack.find_by(identity_type: :slack, uid: identifier)
    @stance   = Stance.new(poll_id: poll_id, choice: choice)
  end

  def participate!
    StanceService.create(stance: @stance, actor: @identity&.user || LoggedOutUser.new)
  rescue CanCan::AccessDenied
    false
  end
end
