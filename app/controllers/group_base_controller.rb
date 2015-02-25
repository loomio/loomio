class GroupBaseController < BaseController

  protected

  def build_discussion_index_caches
    @current_motion_ids = @discussions.map(&:current_motion).compact.map(&:id)

    if current_user
      @motion_readers = MotionReader.where(user_id: current_user.id,
                                           motion_id: @current_motion_ids ).includes(:motion)
      @last_votes = Vote.most_recent.where(user_id: current_user, motion_id: @current_motion_ids)
    else
      @motion_readers = []
      @last_votes = []
    end

    @discussion_reader_cache = DiscussionReaderCache.new(user: current_user, discussions: @discussions)
    @motion_reader_cache = MotionReaderCache.new(current_user, @motion_readers)

    @last_vote_cache = VoteCache.new(current_user, @last_votes)
  end

  def require_current_user_can_invite_people
    unless can? :invite_people, @group
      flash[:error] = "You are not able to invite people to this group"
      redirect_to @group
    end
  end

  def require_current_user_is_group_admin
    unless @group.admins.include? current_user
      flash[:warning] = t("warning.user_not_admin", which_user: current_user.name)
      redirect_to @group
    end
  end

  def load_group
    @group ||= if group_subdomain_present? and group_id.blank?
               Group.published.find_by_subdomain!(subdomain)
             else
               Group.published.find_by_key!(group_id)
             end
  end

  def group_subdomain_present?
    GroupSubdomainConstraint.matches?(request)
  end

  def group_id
    params[:group_id] || params[:id]
  end
end
