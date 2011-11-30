class VotesController < BaseController
  # before_filter :ensure_group_member
  # belongs_to :motion

  # def begin_of_association_chain
  #   @motion
  # end

  def create
    @vote = Vote.new(position: params[:vote][:position])
    @vote.motion = Motion.find(params[:vote][:motion_id])
    @vote.user = current_user
    if @vote.save
      flash[:notice] = 'Vote saved'
      redirect_to group_motion_path(group_id: @vote.motion.group, 
                                    id: @vote.motion)
    else
      render :edit
    end
  end

  private
  def ensure_group_member
    # NOTE: this method is currently duplicated in groups_controller,
    # and motions_controller. We should figure out a way to DRY this up.
    group = Motion.find(params[:vote][:motion_id]).group
    unless group.users.include? current_user
      if group.requested_users_include?(current_user)
        flash[:notice] = "Cannot access group yet... waiting for membership approval."
        redirect_to groups_url
      else
        redirect_to request_membership_group_url(group)
      end
    end
  end
end
