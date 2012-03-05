class VotesController < BaseController
  belongs_to :motion
  # before_filter :ensure_group_member
  # belongs_to :motion

  # def begin_of_association_chain
  #   @motion
  # end

  def destroy
    resource
    if @motion.phase == 'voting'
      destroy! { @motion }
    else
      flash[:error] = "You can only delete your vote during the 'voting' phase"
      redirect_to @motion
    end
  end

  def create
    build_resource
    @vote.user = current_user
    if @motion.phase == 'voting'
      create! { @motion }
    else
      flash[:error] = "Can only vote in voting phase"
      redirect_to @motion
    end
  end

  def update
    resource
    if @motion.phase == 'voting'
      @vote.update_attributes(params[:vote])
      flash[:notice] = "Vote updated."
      @vote.save
    else
      flash[:error] = "Can only vote in voting phase"
    end
    redirect_to @motion
  end

  private
  def ensure_group_member
    # NOTE: this method is currently duplicated in groups_controller,
    # and motions_controller. We should figure out a way to DRY this up.
    group = Motion.find(params[:motion_id]).group
    unless group.users.include? current_user
      if group.requested_users_include?(current_user)
        flash[:error] = "Cannot access group yet... waiting for membership approval."
        redirect_to groups_url
      else
        redirect_to request_membership_group_url(group)
      end
    end
  end
end
