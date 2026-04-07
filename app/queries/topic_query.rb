class TopicQuery
  def self.start
    Topic
      .joins('LEFT JOIN groups ON topics.group_id = groups.id')
      .where('groups.archived_at IS NULL OR topics.group_id IS NULL')
      .includes(:topicable)
  end

  def self.visible_to(chain: start,
                      user: LoggedOutUser.new,
                      group_ids: [],
                      tags: [],
                      or_public: true,
                      or_subgroups: true,
                      only_direct: false,
                      only_unread: false)

    if user.topic_reader_token
      or_topic_reader_token = "OR tr.token = #{ActiveRecord::Base.connection.quote(user.topic_reader_token)}"
    end

    chain = chain.joins("LEFT JOIN topic_readers tr
                         ON tr.topic_id = topics.id
                         AND (tr.user_id = #{user.id || 0} #{or_topic_reader_token})")
                 .where("#{'(topics.private = false) OR ' if or_public}
                         (topics.group_id IN (:user_group_ids)) OR
                         (tr.id IS NOT NULL AND tr.revoked_at IS NULL AND tr.guest = TRUE)
                         #{'OR (groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids))' if or_subgroups}", user_group_ids: user.group_ids)

    chain = chain.where("topics.group_id IN (?)", group_ids) if Array(group_ids).any?
    chain = chain.where("topics.group_id IS NULL")            if only_direct
    chain = chain.where("topics.tags @> ARRAY[?]::varchar[]", tags) if tags.any?

    if only_unread
      chain = chain.where('(tr.dismissed_at IS NULL) OR (tr.dismissed_at < topics.last_activity_at)')
                   .where('tr.last_read_at IS NULL OR (tr.last_read_at < topics.last_activity_at)')
    end

    chain
  end

  def self.filter(chain:, filter:)
    case filter
    when 'show_closed', 'closed' then chain.where.not(closed_at: nil)
    when 'all' then chain
    else chain.where(closed_at: nil)
    end.order(Arel.sql("topics.pinned_at IS NOT NULL DESC, topics.last_activity_at DESC"))
  end
end
