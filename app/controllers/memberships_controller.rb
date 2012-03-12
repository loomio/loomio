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
    build_resource
    @membership.user = current_user
    @membership.access_level = 'request'
    GroupMailer.new_membership_request(@membership.group).deliver
    create! do |format|
      format.html { redirect_to groups_url }
    end
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
