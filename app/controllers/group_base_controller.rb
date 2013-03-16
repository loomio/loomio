class GroupBaseController < BaseController

  private

  def check_group_read_permissions
    if cannot? :show, group
      if user_signed_in?
        render 'groups/private_or_not_found'
      else
        authenticate_user!
      end
    end
  end
end
