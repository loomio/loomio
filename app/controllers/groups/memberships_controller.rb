class Groups::MembershipsController < GroupBaseController
  load_and_authorize_resource :except => [:approve_request, :ignore_request, :cancel_request, :destroy, :index]
  before_filter :require_current_user_is_group_admin, only: [:make_admin, :remove_admin, :index]
  before_filter :load_membership, only: [:make_admin, :remove_admin]

  # membership actions
  def index
    @memberships = @group.memberships
    @group = GroupDecorator.new(Group.find(params[:group_id]))
  end

  def make_admin
    if @membership.member?
      @membership.make_admin!
      flash[:notice] = t("notice.user_made_admin", which_user: @membership.user_name)
    else
      flash[:warning] = t("warning.user_already_admin", which_user: @membership.user_name)
    end
    redirect_to [@group, :memberships]
  end

  def remove_admin
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
    redirect_to [@group, :memberships]
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

  # membership request actions
  # ¡crying! out for their own controller and model
  #
  def approve_request
    @membership = Membership.find(params[:id])
    if @membership.request?
      authorize! :approve_request, @membership
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
      redirect_to group_url(@membership.group)
    else
      flash[:warning] = t("warning.membership_request_already_ignored")
      redirect_to :back
    end
  end

  def cancel_request
    @membership = Membership.find_by_id(params[:id])
    authorize! :cancel_request, @membership
    @group = @membership.group
    @membership.destroy
    flash[:notice] = t("notice.membership_request_canceled")
    redirect_to @group
  end

  def create
    # NOTE (Jon):
    # I feel like this method/action should be renamed to
    # request_membership
    #
    # NOTE (rob)
    # looks ok to me as a REST interface when it's a membership_requests controller
    # cancel -> destroy
    # ignore == cancel?
    # I remember when we decided (together) to make membership requests a membership thing
    # I'm now pretty sure that they should be a seperate model, able to be created by signed in or out users
    # - if the user is signed out then we collect their email and send them an invitation on approval
    # p.s. hi buddy!
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
end
