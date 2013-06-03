class GroupBaseController < BaseController
  protected

  def require_current_user_can_invite_people
    load_group
    unless can? :add_members, @group
      flash[:warning] = t("warning.user_not_admin", which_user: current_user.name)
      redirect_to @group
    end
  end

  def require_current_user_is_group_admin
    load_group
    unless @group.admins.include? current_user
      flash[:warning] = t("warning.user_not_admin", which_user: current_user.name)
      redirect_to group_path(params[:group_id])
    end
  end

  def load_membership
    @membership = @group.memberships.find(params[:id])
  end

  def load_group
    @group ||= Group.find(params[:group_id])
  end

  def check_group_read_permissions
    if cannot? :show, group
      if user_signed_in?
        render 'application/display_error', locals: { message: t('error.group_private_or_not_found') }
      else
        authenticate_user!
      end
    end
  end
end
