module SegmentioHelper

  def segmentio
    segmentio = {user_id: 'undefined',
                   cohort: 'undefined'}
    if current_user
     segmentio.merge!({user_id: current_user.id,
                   cohort: current_user.created_at.strftime("%Y-%m")})
    end

    if @group.present?
      segmentio.merge!({
        group_id: @group.id,
        group_parent_id: (@group.parent_id ? @group.parent_id : 'undefined'),
        top_group: (@group.parent_id ? @group.parent_id : @group.id),
        group_members: @group.memberships_count,
        viewable_by: @group.viewable_by,
        group_cohort: @group.created_at.strftime("%Y-%m")
      })
    end
    if @discussion.present?
      segmentio.merge!({
        discussion_id: params[:id]
      })
    end
  end
end
