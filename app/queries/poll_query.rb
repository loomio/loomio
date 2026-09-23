class PollQuery
  def self.start
    Poll.distinct.kept.includes(:poll_options, :author)
  end

  def self.visible_to(user: LoggedOutUser.new,
                      chain: start,
                      group_ids: [])
    visible_scope(user: user, chain: chain, group_ids: group_ids, public_group_ids: nil)
  end

  def self.relevant_to(user: LoggedOutUser.new,
                       chain: start,
                       group_ids: [])
    visible_scope(user: user, chain: chain, group_ids: group_ids, public_group_ids: group_ids)
  end

  def self.visible_scope(user:,
                         chain:,
                         group_ids:,
                         public_group_ids:)
    return chain.none if user.deactivated_at.present?

    group_ids = Array(group_ids).compact.map(&:to_i)
    public_group_ids = Array(public_group_ids).compact.map(&:to_i) if public_group_ids

    uid = (user.id || 0).to_i
    membership_join = Poll.sanitize_sql_array([
      "LEFT OUTER JOIN memberships m ON m.group_id = t.group_id AND m.user_id = ?",
      uid
    ])
    topic_reader_join = if user.topic_reader_token
      Poll.sanitize_sql_array([
        "LEFT OUTER JOIN topic_readers tr ON tr.topic_id = t.id AND (tr.user_id = ? OR tr.token = ?)",
        uid,
        user.topic_reader_token
      ])
    else
      Poll.sanitize_sql_array([
        "LEFT OUTER JOIN topic_readers tr ON tr.topic_id = t.id AND tr.user_id = ?",
        uid
      ])
    end

    chain = chain.joins("LEFT OUTER JOIN topics t ON t.id = polls.topic_id")
                 .joins("LEFT OUTER JOIN groups g ON g.id = t.group_id")
    chain = chain.where('t.group_id IN (:group_ids)', group_ids: group_ids) if group_ids.any?
    chain = chain.joins(membership_join).joins(topic_reader_join)

    # Parent members may open these polls directly, but they only belong in a
    # relevance feed when the caller is explicitly browsing the subgroup.
    polls = Poll.arel_table
    topics = Topic.arel_table.alias("t")
    groups = Group.arel_table.alias("g")
    memberships = Membership.arel_table.alias("m")
    topic_readers = TopicReader.arel_table.alias("tr")
    visibility = polls[:author_id].eq(uid)
    visibility = visibility.or(topics[:private].eq(false)) if public_group_ids.nil?
    if public_group_ids&.any?
      visibility = visibility.or(topics[:private].eq(false).and(topics[:group_id].in(public_group_ids)))
    end
    visibility = visibility.or(memberships[:id].not_eq(nil).and(memberships[:revoked_at].eq(nil)))
    visibility = visibility.or(
      topic_readers[:id].not_eq(nil)
        .and(topic_readers[:revoked_at].eq(nil))
        .and(topic_readers[:guest].eq(true))
    )
    if public_group_ids.nil? || group_ids.any?
      visibility = visibility.or(
        groups[:parent_members_can_see_discussions].eq(true)
          .and(groups[:parent_id].in(user.group_ids))
      )
    end

    chain = chain.where(visibility)
    # Apply group visibility to every caller, including custom chains and public polls.
    chain.where(topic_id: Topic.left_joins(:group).group_kept.select(:id))
  end

  def self.filter(chain: , params: )
    # how to do this....
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
