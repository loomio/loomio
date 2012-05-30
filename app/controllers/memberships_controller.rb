class MembershipsController < BaseController
  load_and_authorize_resource

  def make_admin
    @membership = Membership.find(params[:id])
    if not @membership.admin?
      @membership.make_admin!
      flash[:notice] = "#{@membership.user_name} has been made an admin."
    else
      flash[:warning] = "#{@membership.user_name} is already an admin."
    end
    redirect_to @membership.group
  end

  def remove_admin
    @membership = Membership.find(params[:id])
    if @membership.admin?
      if @membership.multiple_admins?
        @membership.remove_admin!
        flash[:notice] = "#{@membership.user_name}'s admin rights have been removed."
      else
        flash[:warning] = "You are the last admin and cannot be removed"
      end
    else
      flash[:warning] = "#{@membership.user_name} is not an admin"
    end
    redirect_to @membership.group
  end

  def approve
    @membership = Membership.find(params[:id])
    if @membership.request?
      @membership.approve!
      flash[:notice] = "Membership approved"
    else
      flash[:warning] = "User is already a member of this group"
    end
    UserMailer.group_membership_approved(@membership.user, @membership.group).deliver
    redirect_to @membership.group
  end

  def create
    # NOTE (Jon):
    # I feel like this method/action should be renamed to
    # request_membership
    @group = Group.find(params[:membership][:group_id])
    @group.add_request!(current_user)
    if @group.can_be_viewed_by? current_user
      redirect_to group_url(@group)
    else
      flash[:notice] = "Membership requested."
      redirect_to root_url
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
