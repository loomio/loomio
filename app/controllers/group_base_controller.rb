class GroupBaseController < BaseController

  protected

  def build_discussion_index_caches
    @discussions = [@discussions_with_open_motions.all + @discussions_without_open_motions].flatten

    @current_motions = @discussions_with_open_motions.map{|d| d.current_motion }

    if current_user
      @discussion_readers = DiscussionReader.where(user_id: current_user.id,
                                                    discussion_id: @discussions.map(&:id)).includes(:discussion)
      @motion_readers = MotionReader.where(user_id: current_user.id,
                                           motion_id: @current_motions.map(&:id) ).includes(:motion)
      @last_votes = Vote.most_recent.where(user_id: current_user, motion_id: @current_motions.map(&:id))
    else
      @discussion_readers =[]
      @motion_readers = []
      @last_votes = []
    end

    @discussion_reader_cache = DiscussionReaderCache.new(current_user, @discussion_readers)
    @motion_reader_cache = MotionReaderCache.new(current_user, @motion_readers)

    @last_vote_cache = VoteCache.new(current_user, @last_votes)
  end

  def require_current_user_can_invite_people
    unless can? :invite_people, group
      flash[:error] = "You are not able to invite people to this group"
      redirect_to group
    end
  end

  def require_current_user_is_group_admin
    unless group.admins.include? current_user
      flash[:warning] = t("warning.user_not_admin", which_user: current_user.name)
      redirect_to group
    end
  end

  def group
    @group ||= GroupDecorator.new(Group.published.find_by_key!(group_id))
  end

  def group_id
    params[:group_id] || params[:id]
  end

  def check_group_read_permissions
    if cannot? :show, group
      if user_signed_in?
        render 'application/display_error', locals: { message: t('error.group_private_or_not_found') }
      else
        authenticate_user!
      end
    end
  end
end
