class UsersController < BaseController
  def update
    update! {root_url}
  end

  def settings
    @user = current_user
  end

  def dismiss_system_notice
    current_user.has_read_system_notice = true
    current_user.save!
    redirect_to :back
  end

  def dismiss_dashboard_notice
    current_user.has_read_dashboard_notice = true
    current_user.save!
    redirect_to :back
  end

  def dismiss_group_notice
    current_user.has_read_group_notice = true
    current_user.save!
    redirect_to :back
  end

  def dismiss_discussion_notice
    current_user.has_read_discussion_notice = true
    current_user.save!
    redirect_to :back
  end
end
