class MembershipsController < BaseController
  load_and_authorize_resource

  def update
    resource
    update! do |format|
      format.html { redirect_to @membership.group }
    end
    if params[:membership][:access_level] == 'member'
      flash[:notice] = "Membership approved."
      UserMailer.group_membership_approved(@membership.user, @membership.group).deliver
    end
  end

  def create
    @group = Group.find(params[:membership][:group_id])
    @group.add_request!(current_user)
    redirect_to groups_url
  end

  def destroy
    resource
    destroy! do |format|
      format.html do
        flash[:notice] = "Membership deleted."
        redirect_to @membership.group
      end
    end
  end
end
