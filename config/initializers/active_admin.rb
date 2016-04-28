ActiveAdmin.setup do |config|
  config.site_title = "Loomio"
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_user
  config.logout_link_path = :destroy_user_session_path
  config.root_to = 'groups#index'
  config.batch_actions = true
end

def authenticate_admin_user!
  authenticate_user!
  redirect_to new_user_session_path unless current_user.is_admin?
end
