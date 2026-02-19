class UserQuery
  def self.relations(model:, actor:)
    rels = []
    if model.is_a?(Group) and model.members.exists?(actor.id)
      rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                     where('m.group_id IN (:group_ids) AND m.revoked_at IS NULL', {group_ids: model.group.id})
    end


    if model.nil? or actor.can?(:add_guests, model)
      group_ids = if model && model.group.present? && (!model.is_a?(Group) || model.parent_id)
        actor.group_ids & model.group.parent_or_self.id_and_subgroup_ids
      else
        actor.group_ids
      end

      rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                     where('m.group_id IN (:group_ids) AND m.revoked_at IS NULL', {group_ids: group_ids})

      # people who have been invited by actor
      rels.push(
        User.joins("LEFT OUTER JOIN topic_readers dr on dr.user_id = users.id").
        where("dr.inviter_id = ? AND revoked_at IS NULL AND guest = TRUE", actor.id)
      )

      rels.push(
        User.joins("LEFT OUTER JOIN stances on stances.participant_id = users.id").
        where("stances.inviter_id = ? AND stances.revoked_at IS NULL", actor.id)
      )
    end

    if model.present? && (actor.can?(:add_members, model) || actor.can?(:add_voters, model))
      if model.group.present?
        rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                       where('m.group_id IN (:group_ids) AND m.revoked_at IS NULL', {group_ids: model.group.id})
      end

      discussion = if model.is_a?(Discussion)
        model
      elsif model.respond_to?(:discussion_id) && model.discussion_id
        model.discussion
      end

      if discussion
        topic_id = discussion.topic&.id
        if topic_id
          rels.push(
            User.joins('LEFT OUTER JOIN topic_readers dr ON dr.user_id = users.id').
            where('dr.topic_id': topic_id).where('dr.revoked_at IS NULL and dr.guest = TRUE')
          )
        end

        rels.push(
          User.joins('LEFT OUTER JOIN stances ON stances.participant_id = users.id').
          where('stances.poll_id': Poll.where(topic_id: discussion.topic_id).select(:id)).where("stances.revoked_at IS NULL AND stances.inviter_id IS NOT NULL")
        )
      end

      if model.poll_id
        rels.push(
          User.joins('LEFT OUTER JOIN stances ON stances.participant_id = users.id').
          where('stances.poll_id': model.poll_id).where("stances.revoked_at IS NULL AND stances.inviter_id IS NOT NULL")
        )
      end
    end
    rels
  end

  def self.invitable_user_ids(model: , actor:, user_ids: )
    relations(model: model, actor: actor).map do |rel|
      rel.where(id: user_ids).pluck(:id)
    end.flatten.uniq.compact
  end

  def self.invitable_search(model:, actor:, q: nil, limit: 50)
    ids = relations(model: model, actor: actor).map do |rel|
      rel.active.search_for(q).limit(limit).pluck(:id)
    end.flatten.uniq.compact
    User.where(id: ids).order(:memberships_count).limit(50)
  end
end
