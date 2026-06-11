ActiveAdmin.setup do |config|
  config.site_title = "Loomio"
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_user
  config.logout_link_path = :root_path
  config.logout_link_method = :get
  config.root_to = 'groups#index'
  config.batch_actions = true
  config.comments = false
end

def authenticate_admin_user!
  require_authentication
  redirect_to root_path unless current_user.is_admin?
end
