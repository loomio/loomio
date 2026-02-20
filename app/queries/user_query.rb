class UserQuery
  def self.relations(model:, actor:)
    rels = []
    if model.is_a?(Group) and model.members.exists?(actor.id)
      rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                     where('m.group_id IN (:group_ids) AND m.revoked_at IS NULL', {group_ids: model.id})
    end

    if model.respond_to?(:topic)
      topic = model.topic
      group = topic.group

      group_ids = if group.present?
        actor.group_ids & group.parent_or_self.id_and_subgroup_ids
      else
        actor.group_ids
      end

      rels.push User.joins('LEFT OUTER JOIN memberships m ON m.user_id = users.id').
                     where('m.group_id IN (:group_ids) AND m.revoked_at IS NULL', { group_ids: group_ids })

      rels.push User.joins('LEFT OUTER JOIN topic_readers tr ON tr.user_id = users.id').
                     where('tr.topic_id': topic.id).where('tr.revoked_at IS NULL and tr.guest = TRUE')
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
