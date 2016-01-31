class Groups::MembershipsController < GroupBaseController
  load_and_authorize_resource except: [:index]

  rescue_from CanCan::AccessDenied, with: :only_group_admin

  def index
    load_group
    current_user.ability.authorize! :see_members, @group
    @memberships = @group.memberships.joins(:user).includes(:user).order('name')
    if current_user.is_group_admin?(@group)
      render "coordinator_index"
    else
      render "index"
    end
  end

  def make_admin
    @membership.make_admin!
    flash[:notice] = "#{@membership.user_name} has been made a coordinator."
    redirect_to [@membership.group, :memberships]
  end

  def remove_admin
    @membership.remove_admin!
    flash[:notice] = "#{@membership.user_name}'s coordinator rights have been removed."
    redirect_to [@membership.group, :memberships]
  end

  def destroy
    @membership.destroy
    if current_user == @membership.user
      flash[:notice] = t("notice.you_have_left_group", which_group: @membership.group.name)
      redirect_to dashboard_path
    else
      flash[:notice] = t("notice.member_removed")
      redirect_to [@membership.group, :memberships]
    end
  end

  private

  def only_group_admin
    if action_name == 'destroy'
      flash[:error] = t("error.only_group_coordinator_destroy", add_coordinator: group_memberships_path(@membership.group)).html_safe
      redirect_to @membership.group
    elsif action_name == 'remove_admin'
      flash[:error] = t("error.only_group_coordinator_remove_admin")
      redirect_to [@membership.group, :memberships]
    elsif action_name == 'index'
      flash[:error] = t("error.access_denied")
      redirect_to @group
    else
      flash[:error] = t("error.access_denied")
      redirect_to @membership.group
    end
  end
end
