class AnnouncementService
  class UnknownAudienceKindError < Exception; end

  def self.audience_for(model, kind, actor)
    case kind
    when 'parent_group'     then model.parent.accepted_members.where.not(id: model.member_ids)
    when 'formal_group'     then model.group.accepted_members
    when 'discussion_group' then model.discussion.readers
    when 'voters'           then model.poll.particpants
    when 'undecided'        then model.poll.undecided
    when 'non_voters'       then model.poll.non_voters
    else
      raise UnknownAudienceKindError.new
    end.active.where.not(id: actor.id)
  end

  def self.resend_pending_invitations(since: 25.hours.ago, till: 24.hours.ago)
    Event.invitations_in_period(since, till).each { |event| Events::AnnouncementResend.publish!(event) }
  end
end
