class GroupBaseController < BaseController
  include DiscussionIndexCacheHelper

  protected
  def track_visit
    if user_signed_in?
      ahoy.track_visit
      VisitService.record(visit: current_visit, group: @group, user: current_user)
    end
  end

  def require_current_user_can_invite_people
    unless can? :invite_people, @group
      flash[:error] = "You are not able to invite people to this group"
      redirect_to @group
    end
  end

  def require_current_user_is_group_admin
    unless @group.admins.include? current_user
      flash[:warning] = t("warning.user_not_admin", which_user: current_user.name)
      redirect_to @group
    end
  end

  def load_group
    @group ||= if group_subdomain_present? and group_id.blank?
               Group.published.find_by_subdomain!(subdomain)
             else
               Group.published.find_by_key!(group_id)
             end
  end

  def group_subdomain_present?
    GroupSubdomainConstraint.matches?(request)
  end

  def group_id
    params[:group_id] || params[:id]
  end
end
