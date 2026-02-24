class UserQuery
  def self.relations(model:, actor:)
    rels = []
    if model.nil?
      rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                     where('m.group_id IN (:group_ids) AND m.revoked_at IS NULL', { group_ids: actor.group_ids })

      rels.push User.joins('LEFT OUTER JOIN topic_readers tr ON tr.user_id = users.id').
                     where('tr.inviter_id = ? AND tr.revoked_at IS NULL AND tr.guest = TRUE', actor.id)

      return rels
    end

    if model.is_a?(Group) and model.members.exists?(actor.id)
      group_ids = actor.group_ids & model.parent_or_self.id_and_subgroup_ids
      rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                     where('m.group_id IN (:group_ids) AND m.revoked_at IS NULL', {group_ids: group_ids})
    end

    if model.respond_to?(:topic)
      topic = model.topic
      group = topic.group

      if actor.can?(:add_guests, model)
        group_ids = if group.present?
          actor.group_ids & group.parent_or_self.id_and_subgroup_ids
        else
          actor.group_ids
        end

        rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                       where('m.group_id IN (:group_ids) AND m.revoked_at IS NULL', { group_ids: group_ids })

        rels.push User.joins('LEFT OUTER JOIN topic_readers tr ON tr.user_id = users.id').
                       where('tr.topic_id': topic.id).where('tr.revoked_at IS NULL and tr.guest = TRUE')
      elsif actor.can?(:add_members, model) || actor.can?(:add_voters, model)
        if group.present?
          rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                         where('m.group_id IN (:group_ids) AND m.revoked_at IS NULL', { group_ids: group.id })
        end

        rels.push User.joins('LEFT OUTER JOIN topic_readers tr ON tr.user_id = users.id').
                       where('tr.topic_id': topic.id).where('tr.revoked_at IS NULL and tr.guest = TRUE')
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
