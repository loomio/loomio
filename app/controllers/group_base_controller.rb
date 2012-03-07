class GroupBaseController < BaseController
  private

    def ensure_group_member
      unless group.can_be_edited_by? current_user
        if group.requested_users_include?(current_user)
          flash[:notice] = "Cannot access group yet... waiting for membership approval."
          redirect_to groups_url
        else
          redirect_to request_membership_group_url(group)
        end
      end
    end
end
