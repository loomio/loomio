class MembershipsController < BaseController
  load_and_authorize_resource :except => [:ignore_request, :cancel_request, :destroy]

  def make_admin
    @membership = Membership.find(params[:id])
    if @membership.member?
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
      if @membership.group_has_multiple_admins?
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

  def approve_request
    @membership = Membership.find(params[:id])
    if @membership.request?
      @membership.approve!
      flash[:notice] = "Membership approved"
      UserMailer.group_membership_approved(@membership.user, @membership.group).deliver
    else
      flash[:warning] = "User is already a member of this group"
    end
    redirect_to @membership.group
  end

  def ignore_request
    if @membership = Membership.find_by_id(params[:id])
      authorize! :ignore_request, @membership
      @membership.destroy
      flash[:notice] = "Membership request ignored."
      redirect_to @membership.group
    else
      flash[:warning] = "Membership request has already been ignored."
      redirect_to :back
    end
  end

  def cancel_request
    if @membership = Membership.find_by_id(params[:id])
      authorize! :cancel_request, @membership
      @membership.destroy
      flash[:notice] = "Membership request canceled."
      redirect_to @membership.group
    else
      flash[:warning] = "Membership request has already been canceled."
      redirect_to :back
    end
  end

  def create
    # NOTE (Jon):
    # I feel like this method/action should be renamed to
    # request_membership
    @group = Group.find(params[:membership][:group_id])
    if @group.parent.nil? || current_user.group_membership(@group.parent)
      @group.add_request!(current_user)
      flash[:notice] = "Membership requested."
      if @group.can_be_viewed_by? current_user
        redirect_to group_url(@group)
      else
        redirect_to root_url
      end
    else
      flash[:error] = "You cannot join a sub-group if you are not a member of the parent group."
      redirect_to :back
    end
  end

  def destroy
    if @membership = Membership.find_by_id(params[:id])
      authorize! :destroy, @membership
      @membership.destroy
      if current_user == @membership.user
        flash[:notice] = "You have left #{@membership.group.name}."
      else
        flash[:notice] = "Member removed."
      end
      redirect_to @membership.group
    else
      redirect_to :back
    end
  end
end
