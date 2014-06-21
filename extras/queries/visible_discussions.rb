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

    @relation = Discussion.joins(:group).merge(Group.published).published


    @relation = self.class.apply_privacy_sql(user: @user, group_ids: group_ids, relation: @relation)

    super(@relation)
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

  def unread
    @relation = @relation.joins("LEFT OUTER JOIN discussion_readers dv ON dv.discussion_id = discussions.id AND dv.user_id = #{@user.id}")
    @relation = @relation.where('(dv.last_read_at < discussions.last_comment_at) OR dv.last_read_at IS NULL')
    self
  end

  def self.apply_privacy_sql(user: nil, group_ids: [], relation: nil)
    user_group_ids = user.nil? ? [] : user.cached_group_ids

    # the discussion is public
    # or they are a member of the group
    # or user belongs to parent group and permission is inherited
    #
    relation = relation.where("((discussions.private = :false) OR
                                (group_id IN (:user_group_ids)) OR
                                (groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids)))",
                               false: false,
                               group_ids: group_ids,
                               user_group_ids: user_group_ids)

    if group_ids.present?
      relation = relation.where('group_id in (:group_ids)', group_ids: group_ids)
    end
    relation
  end

end
