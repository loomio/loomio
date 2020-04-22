class DiscussionQuery
  def start
    Discussion.
      joins(:group).
      where('groups.archived_at IS NULL').
      where('discarded_at IS NULL').
      includes(:author, :polls, {group: [:parent]})
  end

  def visible_to(chain: start, user:, group_ids: [], tags: [], show_public: false)
    user = user || LoggedOutUser.new
    group_ids = group_ids || []

    if tags.any?
      chain = chain.joins(:tags).where("tags.name IN (?)", tags)
      # chain = chain.where("(discussions.info->'tags')::jsonb ?& ARRAY[:tags]", tags: tags)
    end

    chain = apply_privacy_sql(user: @user, group_ids: @group_ids, relation: chain, show_public: show_public)
  end

  def unread(chain)
    return chain unless @user.is_logged_in?
    chain.
      where('(dr.dismissed_at IS NULL) OR (dr.dismissed_at < discussions.last_activity_at)').
      where('dr.last_read_at IS NULL OR (dr.last_read_at < discussions.last_activity_at)')
  end

  def muted(chain)
    return chain unless @user.is_logged_in?
    chain.where('(dr.volume = :mute) OR (dr.volume IS NULL AND m.volume = :mute) ',
                {mute: DiscussionReader.volumes[:mute]})
  end

  def not_muted(chain)
    return chain unless @user.is_logged_in?
    chain.where('(dr.volume > :mute) OR (dr.volume IS NULL AND m.volume > :mute)',
                                {mute: DiscussionReader.volumes[:mute]})
  end

  def recent(chain)
    chain.where('last_activity_at > ?', 6.weeks.ago)
  end

  def is_open(chain)
    chain.is_open
  end

  def is_closed(chain)
    chain.is_closed
  end

  def sorted_by_latest_activity(chain)
    chain.order(last_activity_at: :desc)
  end

  def sorted_by_importance(chain)
    chain.order(importance: :desc, last_activity_at: :desc)
  end

  def apply_privacy_sql(user: nil, group_ids: [], relation: nil, show_public: false)
    user ||= LoggedOutUser.new

    if user.discussion_reader_token
      or_discussion_reader_token = "OR dr.token = #{ActiveRecord::Base.connection.quote(user.discussion_reader_token)}"
    end

    relation = relation.where('discussions.group_id IN (:group_ids)', group_ids: group_ids) if group_ids.any?
    relation.joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = discussions.id AND (dr.user_id = #{user.id || 0} #{or_discussion_reader_token})")
            .joins("LEFT OUTER JOIN memberships m ON m.user_id = #{user.id || 0} AND m.group_id = discussions.group_id")
            .where("groups.archived_at IS NULL")
            .where("#{'(discussions.private = false) OR' if show_public}
                    (m.id IS NOT NULL AND m.archived_at IS NULL) OR
                    (dr.id IS NOT NULL AND dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL) OR
                    (groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids))", user_group_ids: user.group_ids)
  end

end
