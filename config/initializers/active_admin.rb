ActiveAdmin.setup do |config|
  config.site_title = "Loomio"
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_user
  config.logout_link_path = :logout_path
  config.logout_link_method = :delete
  config.root_to = 'groups#index'
  config.batch_actions = true
  config.comments = false
end

def authenticate_admin_user!
  unless current_user.is_logged_in?
    redirect_to dashboard_path
    return
  end
  unless current_user.is_admin?
    redirect_to dashboard_path
  end
end

def logout_path
  '/api/v1/sessions'
end
