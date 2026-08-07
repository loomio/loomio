class AnnouncementService
  class UnknownAudienceKindError < Exception; end

  def self.available_audiences(model, actor, include_actor = false)
    audience_candidates(model).filter_map do |audience|
      users = audience_users(model, audience[:id], actor, false, include_actor)
      size = users.count
      audience.merge(size: size) if size.positive?
    rescue CanCan::AccessDenied, ActiveRecord::RecordNotFound
      nil
    end
  end

  def self.audience_users(model, kind, actor, exclude_members = false, include_actor = false)
    poll = poll_for(model)
    users = case kind
    when /group-\d+/
      id = kind.match(/group-(\d+)/)[1].to_i
      group = model.group.parent_or_self.self_and_subgroups.find(id)
      raise CanCan::AccessDenied unless actor.can?(:notify, group)
      group.members
    when /delegates-\d+/
      id = kind.match(/delegates-(\d+)/)[1].to_i
      group = model.group.parent_or_self.self_and_subgroups.find(id)
      raise CanCan::AccessDenied unless actor.can?(:notify, group)
      group.delegates
    when 'group'            then model.group.members
    when 'discussion_group'
      actor.ability.authorize!(:announce, model)
      topic = topic_for(model)
      raise CanCan::AccessDenied unless topic&.readers&.exists?
      topic.readers
    when 'voters'
      raise CanCan::AccessDenied unless poll && poll.voters_count.to_i.positive?
      poll.unmasked_voters
    when 'decided_voters'
      authorize_voter_status_audience!(poll)
      poll.unmasked_decided_voters
    when 'undecided_voters'
      authorize_voter_status_audience!(poll)
      poll.unmasked_undecided_voters
    when 'non_voters'
      raise CanCan::AccessDenied unless poll
      raise CanCan::AccessDenied if poll.detached_anonymous?
      poll.non_voters
    when nil                then User.none
    else
      raise UnknownAudienceKindError.new
    end.active

    users = users.where.not(id: (poll || NullPoll.new).voter_ids) if exclude_members

    include_actor ? users.active.humans : users.active.humans.where('users.id != ?', actor.id)
  end

  def self.audience_candidates(model)
    candidates = []
    topic = topic_for(model)
    poll = poll_for(model)

    candidates << {id: 'discussion_group', kind: 'discussion_group'} if topic&.readers&.exists?

    if poll&.persisted? && poll.voters_count.to_i.positive?
      candidates << {id: 'voters', kind: 'voters'}
      if !poll.detached_anonymous? && poll.decided_voters_count.to_i.positive? && poll.undecided_voters_count.to_i.positive?
        candidates << {id: 'decided_voters', kind: 'decided_voters'}
        candidates << {id: 'undecided_voters', kind: 'undecided_voters'}
      end
    end

    unless model.is_a?(Group)
      group = model.group if model.respond_to?(:group)
      if group.present? && group.persisted?
        groups = [group, group.parent, *group.parent_or_self.subgroups].compact.uniq
        groups.each do |candidate_group|
          candidates << {id: "group-#{candidate_group.id}", kind: 'group', name: candidate_group.name} if candidate_group.members.exists?
          candidates << {id: "delegates-#{candidate_group.id}", kind: 'delegates', name: candidate_group.name} if candidate_group.delegates.exists?
        end
      end
    end

    candidates.uniq { |audience| audience[:id] }
  end

  def self.authorize_voter_status_audience!(poll)
    raise CanCan::AccessDenied unless poll
    raise CanCan::AccessDenied if poll.detached_anonymous?
    raise CanCan::AccessDenied unless poll.decided_voters_count.to_i.positive? && poll.undecided_voters_count.to_i.positive?
  end

  def self.poll_for(model)
    return model if model.is_a?(Poll)
    model.poll if model.respond_to?(:poll)
  end

  def self.topic_for(model)
    return model if model.is_a?(Topic)
    model.topic if model.respond_to?(:topic)
  end

  def self.resend_pending_invitations(since: 25.hours.ago, till: 24.hours.ago)
    Event.invitations_in_period(since, till).each { |event| Events::AnnouncementResend.publish!(event) }
  end

end
