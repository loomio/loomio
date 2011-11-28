class MembershipsController < BaseController
  def update
    resource
    if @membership.group.users.include? current_user
        flash[:notice] = "Membership approved."
        update! do |format|
          format.html { redirect_to @membership.group }
        end
    else
      flash[:error] = "Membership not approved. " + \
        "You cannot approve a membership to a group you don't belong to."
      redirect_to @membership.group
    end
  end

  def create
    build_resource
    @membership.user = current_user
    @membership.access_level = 'request'
    create! do |format|
      format.html { redirect_to groups_url }
    end
  end

  def destroy
    resource
    group = @membership.group
    destroy! do |format|
      format.html do
        flash[:notice] = "Membership request ignored"
        redirect_to group
      end
    end
  end
end
