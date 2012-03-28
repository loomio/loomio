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
    if @group.can_be_viewed_by? current_user
      redirect_to group_url(@group)
    else
      redirect_to groups_url
    end
  end

  def destroy
    resource
    destroy! do |format|
      format.html do
        if @membership.access_level == "request"
          if current_user == @membership.user
            flash[:notice] = "Membership request canceled."
          else
            flash[:notice] = "Membership request ignored."
          end
        else
          if current_user == @membership.user
            flash[:notice] = "You have left #{@membership.group.name}."
          else
            flash[:notice] = "Member removed."
          end
        end
        redirect_to @membership.group
      end
    end
  end
end
