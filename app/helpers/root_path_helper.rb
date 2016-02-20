module RootPathHelper
  protected

  def dashboard_or_root_path
    user_signed_in? ? dashboard_path : root_path
  end
end
