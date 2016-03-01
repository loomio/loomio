module AngularHelper

  def boot_angular_ui
    if browser.ie? && browser.version < 10
      redirect_to :browser_not_supported
    else
      render 'angular/index', layout: false
    end
  end

  private

  def use_angular_ui?
    current_user_or_visitor.angular_ui_enabled? && request.format == :html
  end

  def client_asset_path(filename)
    [:client, angular_asset_folder, filename].join('/')
  end

  private

  def angular_asset_folder
    Rails.env.development? ? :development : Loomio::Version.current
  end

end
