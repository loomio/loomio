class AnnouncementService
  class UnknownAudienceKindError < Exception; end

  def self.audience_users(model, kind)
    case kind
    when 'group'            then model.group.accepted_members
    when 'discussion_group' then model.discussion.readers
    when 'voters'           then model.poll.voters
    when 'participants'     then model.poll.participants
    when 'undecided'        then model.poll.undecided
    when 'non_voters'       then model.poll.non_voters
    when nil                then User.none
    else
      raise UnknownAudienceKindError.new
    end
  end

  def self.audience_relations(model, kind)
    case kind
    when 'group'            then model.group.accepted_memberships
    when 'discussion_group' then model.discussion.discussion_readers
    when 'voters'           then model.poll.stances.latest
    when 'participants'     then model.poll.stances.decided
    when 'undecided'        then model.poll.stances.undecided
    when 'non_voters'       then model.poll.group.memberships.where(user_id: model.poll.non_voters.pluck(:id))
    when nil                then Membership.none
    else
      raise UnknownAudienceKindError.new
    end
  end

  def self.resend_pending_invitations(since: 25.hours.ago, till: 24.hours.ago)
    Event.invitations_in_period(since, till).each { |event| Events::AnnouncementResend.publish!(event) }
  end
end
