class MotionsController < BaseController
  before_filter :ensure_group_member
  belongs_to :group

  def create
    build_resource
    @motion.author = current_user
    create!
  end

  def begin_of_association_chain
    @group
  end

  private
  def ensure_group_member
    # NOTE: this method is currently duplicated in groups_controller,
    # should figure out a way to DRY this up.
    group = Group.find(params[:group_id])
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
