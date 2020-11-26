class DiscussionQuery
  def self.start
    Discussion.
      kept.
      joins('LEFT OUTER JOIN groups ON discussions.group_id = groups.id').
      where('groups.archived_at IS NULL').
      includes(:author, :group)
  end

  def self.dashboard(chain: start, user: )
    chain = chain.where("discussions.group_id IN (:group_ids) OR discussions.id IN (:discussion_ids)",
                         group_ids: user.group_ids, discussion_ids: user.guest_discussion_ids)
    # chain = chain.where("discussions.group_id IN (#{user.groups.select(:id).to_sql}) OR
    #                      discussions.id IN (#{user.guest_discussions.select(:id).to_sql})")
  end

  def self.inbox(chain: start, user: )
    # where("discussions.group_id IN (#{user.groups.select(:id).to_sql})
    #        OR discussions.id IN (#{user.guest_discussions.select(:id).to_sql})").
    chain.joins("LEFT OUTER JOIN discussion_readers dr ON discussions.id = dr.discussion_id AND dr.user_id = #{user.id}").
          where("discussions.group_id IN (:group_ids) OR discussions.id IN (:discussion_ids)", group_ids: user.group_ids, discussion_ids: user.guest_discussion_ids).
          where('dr.dismissed_at IS NULL OR (dr.dismissed_at < discussions.last_activity_at)').
          where('dr.last_read_at IS NULL OR (dr.last_read_at < discussions.last_activity_at)')
  end

  def self.visible_to(chain: start, user: LoggedOutUser.new, group_ids: [], tags: [], only_unread: false, or_public: true, or_subgroups: true)
    if tags.any?
      chain = chain.joins(:tags).where("tags.name IN (?)", tags)
    end

    if user.discussion_reader_token
      or_discussion_reader_token = "OR dr.token = #{ActiveRecord::Base.connection.quote(user.discussion_reader_token)}"
    end

    # chain = chain.joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = discussions.id AND (dr.user_id = #{user.id || 0} #{or_discussion_reader_token})")
    #              .joins("LEFT OUTER JOIN memberships m ON m.user_id = #{user.id || 0} AND m.group_id = discussions.group_id")
    #              .where("groups.archived_at IS NULL")
    #              .where("#{'(discussions.private = false) OR ' if or_public}
    #                      (m.id IS NOT NULL AND m.archived_at IS NULL) OR
    #                      (dr.id IS NOT NULL AND dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL)
    #                      #{'OR (groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids))' if or_subgroups}", user_group_ids: user.group_ids)

    chain = chain.joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = discussions.id AND (dr.user_id = #{user.id || 0} #{or_discussion_reader_token})")
                 .where("#{'(discussions.private = false) OR ' if or_public}
                         (discussions.group_id in (:user_group_ids)) OR
                         (dr.id IS NOT NULL AND dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL)
                         #{'OR (groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids))' if or_subgroups}", user_group_ids: user.group_ids)

    chain = chain.where("discussions.group_id IN (?)", group_ids) if Array(group_ids).any?
    chain = chain.where("discussions.group_id IS NULL") if group_ids.nil?
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
    end.order_by_latest_activity
  end
end
