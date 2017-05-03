class Slack::Participator
  def initialize(uid:, poll_id:, choice:)
    @identity = Identities::Slack.find_by(identity_type: :slack, uid: uid)
    @stance   = Stance.new(poll_id: poll_id, choice: choice)
  end

  def participate!
    StanceService.create(stance: @stance, actor: @identity.user) if can_participate?
  end

  private

  def can_participate?
    @identity&.user&.can?(:create, @stance)
  end
end
