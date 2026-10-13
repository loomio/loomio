class PollQuery
  def self.start
    Poll.distinct.kept.includes(:poll_options, :author)
  end

  def self.visible_to(user: LoggedOutUser.new,
                      chain: start,
                      group_ids: [],
                      topic_id: nil)
    visible_scope(user: user, chain: chain, group_ids: group_ids, relevant: false, topic_id: topic_id)
  end

  def self.relevant_to(user: LoggedOutUser.new,
                       chain: start,
                       group_ids: [])
    visible_scope(user: user, chain: chain, group_ids: group_ids, relevant: true)
  end

  # Topics own poll access. Preserve the narrower dashboard relevance rules
  # and direct authorship access for polls created without an author reader.
  def self.visible_scope(user:, chain:, group_ids:, relevant:, topic_id: nil)
    return chain.none if user.deactivated_at.present?

    group_ids = Array(group_ids).compact.map(&:to_i)
    # Restrict both UNION arms for a single-poll permission check; otherwise
    # PostgreSQL can collect every accessible topic before checking one poll.
    chain = chain.where(topic_id: topic_id) if topic_id
    topics = if relevant
      # Parent-only readers appear in feeds only when browsing that subgroup.
      TopicQuery.relevant_to(user: user, group_ids: group_ids, or_subgroups: group_ids.any?)
    else
      TopicQuery.visible_to(user: user, group_ids: group_ids, topic_id: topic_id)
    end
    visible = chain.where(topic_id: topics.except(:includes).select(:id))
    return visible if group_ids.any?

    direct_topics = Topic.not_discarded.where(group_id: nil).select(:id)
    direct_topics = direct_topics.where(id: topic_id) if topic_id
    visible.or(chain.where(author_id: user.id || 0, topic_id: direct_topics))
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
