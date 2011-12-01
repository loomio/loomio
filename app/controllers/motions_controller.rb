class MotionsController < BaseController
  before_filter :ensure_group_member
  # belongs_to :group

  def new
    @motion = Motion.new(group: Group.find(params[:group_id]))
  end

  def create
    # build_resource
    @motion = Motion.create(params[:motion])
    @motion.author = current_user
    @motion.group = Group.find(params[:group_id])
    @motion.save
    redirect_to motion_url(id: @motion.id)
  end

  private
  def ensure_group_member
    # NOTE: this method is currently duplicated in groups_controller,
    # we should figure out a way to DRY this up.
    if (params[:id] && (params[:id] != "new"))
      group = Motion.find(params[:id]).group
    elsif params[:group_id]
      group = Group.find(params[:group_id])
    end
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
