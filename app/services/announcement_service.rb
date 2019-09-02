class AnnouncementService
  class UnknownAudienceKindError < Exception; end

  def self.audience_for(model, kind, actor)
    case kind
    when 'parent_group'     then model.parent.accepted_members.where.not(id: model.member_ids)
    when 'formal_group'     then model.group.accepted_members
    when 'discussion_group' then model.discussion&.guest_group&.accepted_members
    when 'voters'           then model.poll.participants
    when 'non_voters'       then model.poll.undecided
    else
      raise UnknownAudienceKindError.new
    end.active.where.not(id: actor.id)
  end

  def self.create(model:, params:, actor:)
    actor.ability.authorize! :announce, model
    inviter = GroupInviter.new(
      group:    model.guest_group,
      inviter:  actor,
      emails:   Array(params.dig(:recipients, :emails)),
      user_ids: Array(params.dig(:recipients, :user_ids)),
      invited_group_ids: params[:invited_group_ids]
    ).invite!
    EventBus.broadcast('announcement_create', model, actor, params)
    Events::AnnouncementCreated.publish! model, actor, inviter.invited_memberships, params[:kind]
  end

  def self.resend_pending_memberships(since: 25.hours.ago, till: 24.hours.ago)
    Event.announcements_in_period(since, till).each { |event| Events::AnnouncementResend.publish!(event) }
  end
end
