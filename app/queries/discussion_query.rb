class DiscussionQuery
  def self.start
    Discussion.
      joins(:group).
      where('groups.archived_at IS NULL').
      where('discarded_at IS NULL').
      includes(:author, :active_polls, {group: [:parent]})
  end

  def self.visible_to(chain: start, user: LoggedOutUser.new, group_ids: [], tags: [], only_unread: false, or_public: true, or_subgroups: true)
    if tags.any?
      chain = chain.joins(:tags).where("tags.name IN (?)", tags)
    end

    if user.discussion_reader_token
      or_discussion_reader_token = "OR dr.token = #{ActiveRecord::Base.connection.quote(user.discussion_reader_token)}"
    end

    chain = chain.joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = discussions.id AND (dr.user_id = #{user.id || 0} #{or_discussion_reader_token})")
                 .joins("LEFT OUTER JOIN memberships m ON m.user_id = #{user.id || 0} AND m.group_id = discussions.group_id")
                 .where("groups.archived_at IS NULL")
                 .where("#{'(discussions.private = false) OR ' if or_public}
                         (m.id IS NOT NULL AND m.archived_at IS NULL) OR
                         (dr.id IS NOT NULL AND dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL)
                         #{'OR (groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids))' if or_subgroups}", user_group_ids: user.group_ids)
    chain = chain.where("discussions.group_id IN (?)", group_ids) if group_ids.any?
    if only_unread
      chain = chain.where('(dr.dismissed_at IS NULL) OR (dr.dismissed_at < discussions.last_activity_at)').
        where('dr.last_read_at IS NULL OR (dr.last_read_at < discussions.last_activity_at)')
    end
    chain
  end

  def self.filter(chain: , filter: )
    case filter
    when 'show_closed' then chain.is_closed
    when 'all' then chain
    else chain.is_open
    end.order_by_importance
  end
end
