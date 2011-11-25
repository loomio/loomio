class MembershipsController < BaseController
  def update
    @membership = Membership.find(params[:id])
    if @membership.group.users.include? current_user
        flash[:notice] = "Membership approved."
        update! do |format|
          format.html { redirect_to @membership.group } # group_url(@membership.group) }
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
end
