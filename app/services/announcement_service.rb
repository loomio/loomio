class AnnouncementService
  class UnknownAudienceKindError < Exception; end

  def self.audience_users(model, kind, actor, exclude_members = false)
    users = case kind
    when /group-\d+/
      id = kind.match(/group-(\d+)/)[1].to_i
      group = model.group.parent_or_self.self_and_subgroups.find(id)
      raise CanCan::AccessDenied unless actor.can?(:notify, group)
      group.accepted_members
    when 'group'            then model.group.accepted_members
    when 'discussion_group' then (model.discussion || NullDiscussion.new).readers
    when 'voters'           then (model.poll || NullPoll.new).unmasked_voters
    when 'decided_voters'   then (model.poll || NullPoll.new).unmasked_decided_voters
    when 'undecided_voters' then (model.poll || NullPoll.new).unmasked_undecided_voters
    when 'non_voters'       then (model.poll || NullPoll.new).non_voters
    when nil                then User.none
    else
      raise UnknownAudienceKindError.new
    end.active

    users = users.where.not(id: model.voters.pluck(:id)) if exclude_members
    users
  end

  def self.resend_pending_invitations(since: 25.hours.ago, till: 24.hours.ago)
    Event.invitations_in_period(since, till).each { |event| Events::AnnouncementResend.publish!(event) }
  end
end
