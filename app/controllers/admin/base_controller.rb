class Admin::BaseController < ApplicationController
  skip_before_filter :check_browser, :check_for_invitation
  before_filter :require_admin

  def url_info

    h = {canonical_host: ENV['CANONICAL_HOST'], tld_length: ENV['TLD_LENGTH'], default_subdomain: ENV['DEFAULT_SUBDOMAIN']}

    %w[subdomain domain host port ssl?].each do |method|
      h[method] = request.send method
    end
    render text: h.inspect
  end

  protected

  def require_admin
    unless current_user.present? && current_user.is_admin?
      flash[:error] = "You need to be a system admin for that"
      redirect_to dashboard_path
    end
  end
end
