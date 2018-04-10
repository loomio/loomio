class AnnouncementService
  def self.create(model:, params:, actor:)
    actor.ability.authorize! :announce, model
    inviter = GroupInviter.new(
      group:    model.guest_group,
      inviter:  actor,
      emails:   params.dig(:recipients, :emails),
      user_ids: params.dig(:recipients, :user_ids)
    ).invite!
    EventBus.broadcast('announcement_create', model, actor, params)
    Events::AnnouncementCreated.bulk_publish! model, actor, inviter.invited_memberships, params[:kind]
  end
end
