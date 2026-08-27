# Resolve a user-selected audience at notification creation time. The returned
# relation is snapshotted as recipient IDs so membership changes between the
# request and background delivery cannot change who the actor addressed.
class NotificationAudienceService
  class UnknownAudienceKindError < StandardError; end

  def self.available(model:, actor:, exclude_members: false, include_actor: false)
    audience_candidates(model).filter_map do |audience|
      users = resolve(
        model: model,
        kind: audience[:id],
        actor: actor,
        exclude_members: exclude_members,
        include_actor: include_actor
      )
      size = users.count
      audience.merge(size: size) if size.positive?
    rescue CanCan::AccessDenied, ActiveRecord::RecordNotFound
      nil
    end
  end

  def self.resolve(model:, kind:, actor:, exclude_members: false, include_actor: false)
    poll = poll_for(model)
    users = case kind
    when /\Agroup-(\d+)\z/
      id = Regexp.last_match(1).to_i
      group = group_audience_scope(model).find(id)
      action = model.is_a?(Group) ? :members_autocomplete : :notify
      raise CanCan::AccessDenied unless actor.can?(action, group)
      group.members
    when /\Adelegates-(\d+)\z/
      id = Regexp.last_match(1).to_i
      group = group_audience_scope(model).find(id)
      raise CanCan::AccessDenied unless actor.can?(:notify, group)
      group.delegates
    when "group"
      authorize_notify!(model: model, actor: actor)
      group_for(model).members
    when "topic"
      authorize_notify!(model: model, actor: actor)
      topic = topic_for(model)
      raise CanCan::AccessDenied unless topic&.readers&.exists?
      topic.readers
    when "voters"
      raise CanCan::AccessDenied unless poll && poll.voters_count.to_i.positive?
      poll.unmasked_voters
    when "decided_voters"
      authorize_voter_status_audience!(poll)
      poll.unmasked_decided_voters
    when "undecided_voters"
      authorize_voter_status_audience!(poll)
      poll.unmasked_undecided_voters
    when "non_voters"
      raise CanCan::AccessDenied unless poll
      raise CanCan::AccessDenied if poll.detached_anonymous?
      poll.non_voters
    when nil then User.none
    else
      raise UnknownAudienceKindError
    end.active

    if exclude_members
      member_ids = model.is_a?(Group) ? model.member_ids : (poll || NullPoll.new).voter_ids
      users = users.where.not(id: member_ids)
    end

    include_actor ? users.active.humans : users.active.humans.where.not(id: actor.id)
  end

  # Group-backed audiences share the group's notification permission regardless
  # of whether their members come from the group or the current topic.
  def self.authorize_notify!(model:, actor:)
    group = group_for(model)
    if group.present?
      actor.ability.authorize!(:notify, group)
    else
      actor.ability.authorize!(:announce, model)
    end
  end

  def self.audience_candidates(model)
    candidates = []
    topic = topic_for(model)
    poll = poll_for(model)

    candidates << { id: "topic", kind: "topic" } if topic&.readers&.exists?

    if poll&.persisted? && poll.voters_count.to_i.positive?
      candidates << { id: "voters", kind: "voters" }
      if !poll.detached_anonymous? && poll.decided_voters_count.to_i.positive? && poll.undecided_voters_count.to_i.positive?
        candidates << { id: "decided_voters", kind: "decided_voters" }
        candidates << { id: "undecided_voters", kind: "undecided_voters" }
      end
    end

    group = group_for(model)
    if group.present? && group.persisted?
      groups = if model.is_a?(Group)
        group_audience_scope(model).to_a
      else
        [ group, group.parent, *group.parent_or_self.subgroups ].compact.uniq
      end
      groups.each do |candidate_group|
        if candidate_group.members.exists?
          candidates << { id: "group-#{candidate_group.id}", kind: "group", name: candidate_group.name }
        end
        if !model.is_a?(Group) && candidate_group.delegates.exists?
          candidates << { id: "delegates-#{candidate_group.id}", kind: "delegates", name: candidate_group.name }
        end
      end
    end

    candidates.uniq { |audience| audience[:id] }
  end

  def self.authorize_voter_status_audience!(poll)
    raise CanCan::AccessDenied unless poll
    raise CanCan::AccessDenied if poll.detached_anonymous?
    unless poll.decided_voters_count.to_i.positive? && poll.undecided_voters_count.to_i.positive?
      raise CanCan::AccessDenied
    end
  end

  def self.poll_for(model)
    return model if model.is_a?(Poll)

    model.poll if model.respond_to?(:poll)
  end

  def self.group_for(model)
    return model if model.is_a?(Group)

    model.group if model.respond_to?(:group)
  end

  def self.group_audience_scope(model)
    scope = group_for(model).parent_or_self.self_and_subgroups
    model.is_a?(Group) ? scope.where.not(id: model.id) : scope
  end

  def self.topic_for(model)
    return model if model.is_a?(Topic)

    model.topic if model.respond_to?(:topic)
  end

  private_class_method :audience_candidates,
                       :authorize_voter_status_audience!,
                       :group_audience_scope,
                       :group_for,
                       :poll_for,
                       :topic_for
end
