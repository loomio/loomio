class Groups::MembershipsController < GroupBaseController
  load_and_authorize_resource except: [:index]
  before_filter :require_current_user_is_group_admin, only: [:index]

  def index
    @memberships = @group.memberships
    @group = GroupDecorator.new(Group.find(params[:group_id]))
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
      redirect_to root_path
    else
      flash[:notice] = t("notice.member_removed")
      redirect_to [@membership.group, :memberships]
    end
  end
end
