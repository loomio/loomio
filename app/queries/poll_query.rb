class PollQuery
  def self.start
    Poll.distinct.kept.includes(:poll_options, :author)
  end

  def self.visible_to(user: LoggedOutUser.new,
                      chain: start,
                      group_ids: [])
    visible_scope(user: user, chain: chain, group_ids: group_ids, relevant: false)
  end

  def self.relevant_to(user: LoggedOutUser.new,
                       chain: start,
                       group_ids: [])
    visible_scope(user: user, chain: chain, group_ids: group_ids, relevant: true)
  end

  # Visibility grants access through direct authorship, membership, guests, or
  # public content. Relevance limits public and parent-member access to the
  # groups being browsed. Archived groups are excluded from every access path.
  def self.visible_scope(user:, chain:, group_ids:, relevant:)
    return chain.none if user.deactivated_at.present?

    group_ids = Array(group_ids).compact.map(&:to_i)
    bindings = {
      user_id: user.id || 0,
      user_group_ids: user.group_ids,
      group_ids: group_ids,
      topic_reader_token: user.topic_reader_token
    }
    reader_identity = "tr.user_id = :user_id"
    reader_identity += " OR tr.token = :topic_reader_token" if user.topic_reader_token

    joins = Poll.sanitize_sql_array([<<~SQL.squish, bindings])
      LEFT OUTER JOIN topics t ON t.id = polls.topic_id
      LEFT OUTER JOIN groups g ON g.id = t.group_id
      LEFT OUTER JOIN memberships m ON m.group_id = t.group_id AND m.user_id = :user_id
      LEFT OUTER JOIN topic_readers tr ON tr.topic_id = t.id AND (#{reader_identity})
    SQL

    chain = chain.joins(joins)
    chain = chain.where('t.group_id IN (:group_ids)', bindings) if group_ids.any?

    # Authorship alone grants access only to direct polls.
    visibility = [
      "(polls.author_id = :user_id AND t.group_id IS NULL)",
      "(m.id IS NOT NULL AND m.revoked_at IS NULL)",
      "(tr.id IS NOT NULL AND tr.revoked_at IS NULL AND tr.guest = TRUE)"
    ]
    if relevant
      visibility << "(t.private = FALSE AND t.group_id IN (:group_ids))" if group_ids.any?
    else
      visibility << "t.private = FALSE"
    end

    # Parent-only readers appear in feeds only when browsing that subgroup.
    if !relevant || group_ids.any?
      visibility << "(g.parent_members_can_see_discussions = TRUE AND g.parent_id IN (:user_group_ids))"
    end

    # Apply group visibility to every caller, including custom chains and public polls.
    chain.where(visibility.join(" OR "), bindings)
         .where(topic_id: Topic.left_joins(:group).group_kept.select(:id))
  end

  def self.filter(chain:, params:)
    if params[:group_key].present? && (group = Group.find_by(key: params[:group_key]))
      group_ids = (params[:subgroups] == "none") ? [group.id] : group.id_and_subgroup_ids
      chain = chain.joins(:topic).where("topics.group_id": group_ids)
    end

    if discussion = Discussion.find_by(key: params[:discussion_key]) || Discussion.find_by(id: params[:discussion_id])
      chain = chain.where(topic_id: discussion.topic_id)
    end

    if (tags = (params[:tags] || '').split('|')).any?
      chain = chain.joins(:topic).where("topics.tags @> ARRAY[?]::varchar[]", tags)
    end

    if params[:status] == 'vote'
      voted_poll_ids = Stance.where(latest: true).where.not(cast_at: nil).pluck(:poll_id)
      chain = chain.where.not(id: voted_poll_ids)
    end

    chain = chain.where(author_id: params[:author_id]) if params[:author_id]
    chain = chain.where(poll_type: params[:poll_type]) if params[:poll_type]
    chain = chain.send(params[:status]) if %w(active closed recent template).include?(params[:status])
    chain = chain.search_for(params[:query]) if params[:query]
    chain
  end
end
