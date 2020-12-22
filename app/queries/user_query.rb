class UserQuery
  def self.relations(model:, actor:)
    rels = []
    if model.is_a?(Group) and model.members.exists?(actor.id)
      rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                     where('(m.group_id IN (:group_ids))', {group_ids: model.group.id})
    end

    if model.nil? or actor.can?(:add_guests, model)
      group_ids = if model && model.group.present? && (!model.is_a?(Group) || model.parent_id)
        actor.group_ids & model.group.parent_or_self.id_and_subgroup_ids
      else
        actor.group_ids
      end

      rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                     where('(m.group_id IN (:group_ids))', {group_ids: group_ids})

      # people who have invited actor
      rels.push(
        User.joins("LEFT OUTER JOIN discussion_readers dr on dr.inviter_id = users.id").
             where("dr.user_id = ? AND inviter_id IS NOT NULL AND revoked_at IS NULL", actor.id)
      )

      # people who have been invited by actor
      rels.push(
        User.joins("LEFT OUTER JOIN discussion_readers dr on dr.user_id = users.id").
        where("dr.inviter_id = ? AND revoked_at IS NULL", actor.id)
      )

      # people who have invited actor
      rels.push(
        User.joins("LEFT OUTER JOIN stances on stances.inviter_id = users.id").
        where("stances.participant_id = ? AND revoked_at IS NULL", actor.id)
      )

      # people who have been invited by actor
      rels.push(
        User.joins("LEFT OUTER JOIN stances on stances.participant_id = users.id").
        where("stances.inviter_id = ? AND revoked_at IS NULL", actor.id)
      )
    end

    if model.present? and actor.can?(:add_members, model)
      if model.group.present?
        rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                       where('(m.group_id IN (:group_ids))', {group_ids: model.group.id})
      end


      if model.discussion_id
        rels.push(
          User.joins('LEFT OUTER JOIN discussion_readers dr ON dr.user_id = users.id').
          where('dr.discussion_id': model.discussion_id)
        )

        rels.push(
          User.joins('LEFT OUTER JOIN stances ON stances.participant_id = users.id').
          where('stances.poll_id': model.discussion.poll_ids)
        )
      end

      if model.poll_id
        rels.push(
          User.joins('LEFT OUTER JOIN stances ON stances.participant_id = users.id').
          where('stances.poll_id': model.poll_id)
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
      rel.active.verified.search_for(q).limit(limit).pluck(:id)
    end.flatten.uniq.compact
    User.where(id: ids).order(:memberships_count).limit(50)
  end
end
