module AnalyticsDataHelper

  def analytics_data_tag
    tag = {user_id: 'undefined',
                 cohort: 'undefined'}

    if current_user
     tag.merge!({user_id: current_user.id,
                       cohort: current_user.created_at.strftime("%Y-%m")})
    end

    if @discussion.present?
      tag.merge!({ discussion_id: @discussion.id })
      @group = @discussion.group if @group.nil?
    end

    if @group.present? and @group.persisted?
      tag.merge!({
        group_id: @group.id,
        group_parent_id: (@group.parent_id ? @group.parent_id : 'undefined'),
        top_group: (@group.parent_id ? @group.parent_id : @group.id),
        group_memberships_count: @group.memberships_count,
        group_privacy: @group.privacy,
        group_cohort: @group.created_at.strftime("%Y-%m")
      })
    end

    tag
  end
end
