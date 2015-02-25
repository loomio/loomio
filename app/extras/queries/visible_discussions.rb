class Queries::VisibleDiscussions < Delegator
  def initialize(user: nil, groups: nil, group_ids: nil)
    @user = user

    if group_ids.nil?
      if groups.present?
        group_ids = Array(groups).map(&:id)
      elsif user.present?
        group_ids = user.group_ids
      end
    end

    @relation = Discussion.joins(:group).where('groups.archived_at IS NULL').published


    @relation = self.class.apply_privacy_sql(user: @user, group_ids: group_ids, relation: @relation)

    super(@relation)
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

  def join_to_discussion_readers
    unless @joined_to_discussion_readers
      @relation = @relation.joins("LEFT OUTER JOIN discussion_readers dv ON dv.discussion_id = discussions.id AND dv.user_id = #{@user.id}")
      @joined_to_discussion_readers = true
    end
    self
  end

  def unread
    join_to_discussion_readers
    @relation = @relation.where('dv.last_read_at IS NULL OR (dv.last_read_at < discussions.last_activity_at)')
    self
  end

  def discussion_newer_than_membership
    unless @filtering_old_discussions
      @relation = @relation.joins("LEFT OUTER JOIN memberships m ON discussions.group_id = m.group_id AND m.user_id = #{@user.id}").
                          where('discussions.created_at > m.created_at')
      @filtering_old_discussions = true
    end
    self
  end

  def following
    join_to_discussion_readers
    followed_group_ids = @user.memberships.where(following_by_default: true).pluck(:group_id)
    @relation = @relation.where('(dv.following = :true) OR (dv.following IS NULL and discussions.group_id IN (:followed_group_ids))',
                                {true: true, followed_group_ids: followed_group_ids})
    self
  end


  def self.apply_privacy_sql(user: nil, group_ids: [], relation: nil)
    user_group_ids = user.nil? ? [] : user.cached_group_ids

    # select where
    # the discussion is public
    # or they are a member of the group
    # or user belongs to parent group and permission is inherited

    relation = relation.where("((discussions.private = :false) OR
                                (discussions.group_id IN (:user_group_ids)) OR
                                (groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids)))",
                               false: false,
                               group_ids: group_ids,
                               user_group_ids: user_group_ids)

    if group_ids.present?
      relation = relation.where('discussions.group_id in (:group_ids)', group_ids: group_ids)
    end
    relation
  end

end
