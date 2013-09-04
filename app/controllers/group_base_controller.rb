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
      redirect_to group_path(@group.id)
    end
  end

  def load_membership
    load_group
    @membership = @group.memberships.find(params[:id])
  end

  def load_group
    @group ||= GroupDecorator.new(Group.find(group_id))
  end

  def group_id
    params[:group_id] || params[:id]
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

  def prepare_segmentio_data
    super
    load_group
    @segmentio.merge!({
      group_id: @group.id,
      group_parent_id: (@group.parent_id ? @group.parent_id : 'undefined'),
      top_group: (@group.parent_id ? @group.parent_id : @group.id),
      group_members: @group.memberships_count,
      viewable_by: @group.viewable_by,
      group_cohort: @group.created_at.strftime("%Y-%m")
    })
  end
end
