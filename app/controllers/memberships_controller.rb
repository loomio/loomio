class MembershipsController < BaseController
  load_and_authorize_resource :except => [:ignore_request, :cancel_request, :destroy]

  def make_admin
    @membership = Membership.find(params[:id])
    if @membership.member?
      @membership.make_admin!
      flash[:notice] = t("notice.user_made_admin", which_user: @membership.user_name)
    else
      flash[:warning] = t("warning.user_already_admin", which_user: @membership.user_name)
    end
    redirect_to @membership.group
  end

  def remove_admin
    @membership = Membership.find(params[:id])
    if @membership.admin?
      if @membership.group_has_multiple_admins?
        @membership.remove_admin!
        flash[:notice] = t("notice.admin_rights_removed", which_user: @membership.user_name)
      else
        flash[:warning] = t("warning.cant_remove_last_admin")
      end
    else
      flash[:warning] = t("warning.user_not_admin", which_user: @membership.user_name)
    end
    redirect_to @membership.group
  end

  def approve_request
    @membership = Membership.find(params[:id])
    if @membership.request?
      @membership.approve!
      flash[:notice] = t("notice.membership_approved")
      UserMailer.group_membership_approved(@membership.user, @membership.group).deliver
    else
      flash[:warning] = t("warning.user_already_member")
    end
    redirect_to @membership.group
  end

  def ignore_request
    if @membership = Membership.find_by_id(params[:id])
      authorize! :ignore_request, @membership
      @membership.destroy
      flash[:notice] = t("notice.membership_request_ignored")
      redirect_to @membership.group
    else
      flash[:warning] = t("warning.membership_request_already_ignored")
      redirect_to :back
    end
  end

  def cancel_request
    if @membership = Membership.find_by_id(params[:id])
      authorize! :cancel_request, @membership
      @membership.destroy
      flash[:notice] = t("notice.membership_request_canceled")
      redirect_to @membership.group
    else
      flash[:warning] = t("warning.membership_request_already_canceled")
      redirect_to :back
    end
  end

  def create
    # NOTE (Jon):
    # I feel like this method/action should be renamed to
    # request_membership
    @group = Group.find(params[:membership][:group_id])
    if @group.parent.nil? || current_user.group_membership(@group.parent)
      membership = @group.add_request!(current_user)
      Events::MembershipRequested.publish!(membership)
      flash[:notice] = t("notice.membership_requested")
      redirect_to group_url(@group)
    else
      flash[:error] = t("error.cant_join_subgroup")
      redirect_to :back
    end
  end

  def destroy
    if @membership = Membership.find_by_id(params[:id])
      authorize! :destroy, @membership
      @membership.destroy
      if current_user == @membership.user
        flash[:notice] = t("notice.you_have_left_group", which_group: @membership.group.name)
      else
        flash[:notice] = t("notice.member_removed")
      end
      redirect_to @membership.group
    else
      redirect_to :back
    end
  end
end
