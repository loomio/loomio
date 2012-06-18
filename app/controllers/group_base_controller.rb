class GroupBaseController < BaseController
  before_filter :authenticate_user!, except: :show

  private
    def check_group_read_permissions
      unless can? :show, group
        if current_user
          render 'groups/private_or_not_found'
        else
          authenticate_user!
        end
      end
    end
end
