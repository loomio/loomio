class TopicQuery
  def self.start
    Topic
      .joins('LEFT JOIN groups ON topics.group_id = groups.id')
      .where('groups.archived_at IS NULL OR topics.group_id IS NULL')
      .where('topics.discarded_at': nil)
      .includes(:topicable)
  end

  def self.visible_to(chain: start,
                      user: LoggedOutUser.new,
                      group_ids: [],
                      tags: [],
                      or_subgroups: true,
                      only_direct: false,
                      only_unread: false)
    visible_scope(chain: chain, user: user, group_ids: group_ids, tags: tags, or_subgroups: or_subgroups, only_direct: only_direct, only_unread: only_unread, public_group_ids: nil)
  end

  def self.relevant_to(chain: start,
                       user: LoggedOutUser.new,
                       group_ids: [],
                       tags: [],
                       or_subgroups: true,
                       only_direct: false,
                       only_unread: false)
    visible_scope(chain: chain, user: user, group_ids: group_ids, tags: tags, or_subgroups: or_subgroups, only_direct: only_direct, only_unread: only_unread, public_group_ids: group_ids)
  end

  def self.visible_scope(chain:,
                         user:,
                         group_ids:,
                         tags:,
                         or_subgroups:,
                         only_direct:,
                         only_unread:,
                         public_group_ids:)
    group_ids = Array(group_ids).compact.map(&:to_i)
    public_group_ids = Array(public_group_ids).compact.map(&:to_i) if public_group_ids

    uid = (user.id || 0).to_i
    topic_reader_join = if user.topic_reader_token
      Topic.sanitize_sql_array(["LEFT JOIN topic_readers tr ON tr.topic_id = topics.id AND (tr.user_id = ? OR tr.token = ?)", uid, user.topic_reader_token])
    else
      Topic.sanitize_sql_array(["LEFT JOIN topic_readers tr ON tr.topic_id = topics.id AND tr.user_id = ?", uid])
    end

    guest_topic_reader_join = if user.topic_reader_token
      Topic.sanitize_sql_array(["JOIN topic_readers tr ON tr.topic_id = topics.id AND (tr.user_id = ? OR tr.token = ?) AND tr.revoked_at IS NULL AND tr.guest = TRUE", uid, user.topic_reader_token])
    else
      Topic.sanitize_sql_array(["JOIN topic_readers tr ON tr.topic_id = topics.id AND tr.user_id = ? AND tr.revoked_at IS NULL AND tr.guest = TRUE", uid])
    end

    # Arm 1: topics visible via group membership (the dominant path).
    # Separated from the guest arm so the planner can use the
    # (group_id, last_activity_at) index without being blocked by the OR.
    member_visibility = []
    member_visibility << "topics.private = false" unless public_group_ids
    member_visibility << "topics.private = false AND topics.group_id IN (:public_group_ids)" if public_group_ids&.any?
    member_visibility << "topics.group_id IN (:user_group_ids)"
    member_visibility << "groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids)" if or_subgroups
    member_params = { user_group_ids: user.group_ids }
    member_params[:public_group_ids] = public_group_ids if public_group_ids&.any?

    arm1 = Topic.select("topics.*")
      .joins("LEFT JOIN groups ON topics.group_id = groups.id")
      .joins(topic_reader_join)
      .where("groups.archived_at IS NULL OR topics.group_id IS NULL")
      .where(discarded_at: nil)
      .where(member_visibility.join(" OR "), member_params)

    # Arm 2: topics the user has been explicitly invited to as a guest (rare).
    # Uses the (user_id, topic_id) WHERE guest = TRUE index for a near-instant lookup.
    arm2 = Topic.select("topics.*")
      .joins("LEFT JOIN groups ON topics.group_id = groups.id")
      .joins(guest_topic_reader_join)
      .where("groups.archived_at IS NULL OR topics.group_id IS NULL")
      .where(discarded_at: nil)

    arms = [arm1, arm2].map do |arm|
      arm = arm.where("topics.group_id IN (?)", group_ids) if group_ids.any?
      arm = arm.where("topics.group_id IS NULL")            if only_direct
      arm = arm.where("topics.tags @> ARRAY[?]::varchar[]", tags) if tags.any?
      if only_unread
        arm = arm
          .where("(tr.dismissed_at IS NULL) OR (tr.dismissed_at < topics.last_activity_at)")
          .where("tr.last_read_at IS NULL OR (tr.last_read_at < topics.last_activity_at)")
      end
      arm
    end

    Topic
      .from("(#{arms[0].to_sql} UNION ALL #{arms[1].to_sql}) AS topics")
      .includes(:topicable)
  end

  def self.public_visibility_sql(public_group_ids)
    return "" unless public_group_ids.any?

    "(topics.private = false AND topics.group_id IN (:public_group_ids)) OR "
  end

  def self.filter(chain:, filter:)
    case filter
    when 'locked' then chain.where.not(locked_at: nil)
    when 'unlocked' then chain.where(locked_at: nil)
    else chain
    end.order(Arel.sql("topics.pinned_at IS NOT NULL DESC, topics.last_activity_at DESC"))
  end
end
