class AnnouncementService
  class UnknownAudienceKindError < Exception; end

  def self.audience_for(model, kind, actor)
    case kind
    when 'formal_group'
      Queries::UsersByVolumeQuery.normal_or_loud(model.group)
    when 'discussion_group'
      Queries::UsersByVolumeQuery.normal_or_loud(model.discussion&.guest_group)
    when 'voters'
      model.poll.participants
    when 'non_voters'
      model.poll.undecided
    else
      raise UnknownAudienceKindError.new
    end.where.not(id: actor.id)
  end

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
