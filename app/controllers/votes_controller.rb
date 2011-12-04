class VotesController < BaseController
  # before_filter :ensure_group_member
  # belongs_to :motion

  # def begin_of_association_chain
  #   @motion
  # end

  def new
    @vote = Vote.new(motion: Motion.find(params[:motion_id]))
  end

  def destroy
    destroy! { @vote.motion }
  end

  def create
    motion = Motion.find(params[:motion_id])
    if motion.motion_type == 'discussion'
      flash[:error] = "Can't vote on a discussion"
      redirect_to motion
    else
      vote = Vote.where("user_id = ? AND motion_id = ?", current_user.id, motion.id)
      if vote.exists?
        flash[:error] = 'Only one vote is allowed per user'
        redirect_to motion
        return
      end
      @vote = Vote.new(params[:vote])
      @vote.motion = motion
      @vote.user = current_user
      if @vote.save
        flash[:notice] = 'Vote saved'
        redirect_to @vote.motion
      else
        render :edit
      end
    end
  end

  def update
    update! { motion_path(@vote.motion) }
  end

  private
  def ensure_group_member
    # NOTE: this method is currently duplicated in groups_controller,
    # and motions_controller. We should figure out a way to DRY this up.
    group = Motion.find(params[:motion_id]).group
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
