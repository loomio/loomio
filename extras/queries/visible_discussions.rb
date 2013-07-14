class Queries::VisibleDiscussions < Delegator
  def initialize(user: nil, group: nil, subgroups: false)
    @user = user
    @group = group

    @relation = Discussion.joins(:group).where('groups.archived_at IS NULL').order('last_comment_at DESC')

    @relation = if group
                  if subgroups
                    @relation.where('group_id = :id OR groups.parent_id = :id', id: group.id)
                  else
                    @relation.where(group_id: group.id)
                  end
                else
                  @relation
                end

    @relation = if @user
                  @relation = @relation.
                    select('discussions.*,
                            1 as joined_to_discussion_reader,
                            dv.id as viewer_id,
                            dv.user_id as viewer_user_id,
                            dv.read_comments_count as read_comments_count,
                            dv.last_read_at as last_read_at,
                            dv.following as viewer_following').
                    joins("LEFT OUTER JOIN discussion_readers dv ON
                            dv.discussion_id = discussions.id AND dv.user_id = #{@user.id}")
                  if group
                    if group.viewable_by == 'parent_group_members'
                      @relation = @relation.where('groups.id IN (:ids) OR (groups.viewable_by = :parent_group_members AND groups.parent_id IN (:ids))', {ids: user.group_ids, :parent_group_members => 'parent_group_members'} )
                    elsif group.viewable_by == 'everyone'
                      #we have some .. interesting behaviours in loomio.
                      if subgroups
                        @relation = @relation.where('groups.id IN (:ids) OR 
                                                  (groups.viewable_by = :everyone AND groups.id = :group_id) OR
                                                  (groups.viewable_by = :everyone AND groups.parent_id = :group_id)', {ids: user.group_ids, :everyone => 'everyone', :group_id => group.id})
                      else
                        @relation = @relation.where('groups.id IN (:ids) OR 
                                                  (groups.viewable_by = :everyone AND groups.id = :group_id)', {ids: user.group_ids, :everyone => 'everyone', :group_id => group.id})
                      end
                    else
                      @relation = @relation.where(groups: {id: user.group_ids})
                    end
                  end
                  @relation
                else
                  # only public groups
                  @relation.where('groups.viewable_by = ?', 'everyone')
                end

    super(@relation)
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

  def unread
    @relation = @relation.where('(dv.last_read_at < discussions.last_comment_at) OR dv.last_read_at IS NULL')
    self
  end

  def followed
    @relation = @relation.where('dv.following = ? OR dv.following IS NULL', true)
    self
  end

  def without_current_motions
    @relation = @relation.where("discussions.id NOT IN (SELECT discussion_id FROM motions WHERE id IS NOT NULL AND closed_at IS NULL)")
    self
  end
end
