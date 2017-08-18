class Admin::BaseController < ApplicationController
  skip_before_filter :check_browser, :check_for_invitation
  before_filter :require_admin

  protected

  def require_admin
    unless current_user.present? && current_user.is_admin?
      flash[:error] = "You need to be a system admin for that"
      redirect_to dashboard_path
    end
  end
end
