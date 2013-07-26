class Groups::MembershipsController < GroupBaseController
  load_and_authorize_resource :except => [:destroy, :index]
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
        redirect_to root_url
      else
        flash[:notice] = t("notice.member_removed")
        redirect_to group_memberships_path(@membership.group)
      end
    else
      redirect_to :back
    end
  end

end
