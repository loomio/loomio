class Slack::Participator
  def self.participate!(identifier:, poll_id:, choice:)
    StanceService.create(
      stance: Stance.new(poll_id: poll_id, choice: choice),
      actor: actor_for(identifier)
    )
  rescue CanCan::AccessDenied
    false
  end

  def self.actor_for(identifier)
    Identities::Slack.find_by(identity_type: :slack, uid: identifier)&.user || LoggedOutUser.new
  end
  private_class_method :actor_for

end
