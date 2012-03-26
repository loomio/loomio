class GroupBaseController < BaseController
  private

    def check_group_read_permissions
      unless group.can_be_viewed_by? current_user
        if group.requested_users_include?(current_user)
          flash[:notice] = "Cannot access group yet... waiting for membership approval."
          redirect_to groups_url
        else
          redirect_to request_membership_group_url(group)
        end
      end
    end
end
