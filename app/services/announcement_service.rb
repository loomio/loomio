class AnnouncementService
  class UnknownAudienceKindError < Exception; end

  def self.audience_for(model, kind, actor)
    case kind
    when 'formal_group' then model.group.members
    when 'discussion_group' then model.discussion&.guest_group&.members
    when 'voters' then model.poll.participants
    when 'non_voters' then model.poll.undecided
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
    Events::AnnouncementCreated.publish! model, actor, inviter.invited_memberships, params[:kind]
  end

  def self.resend_pending_memberships
    Events::AnnouncementCreated.where(kind: "announcement_created").
          within(25.hours.ago.beginning_of_hour, 24.hours.ago.beginning_of_hour).each do |event|
      Events::AnnouncementResend.publish!(event)
    end
  end
end
