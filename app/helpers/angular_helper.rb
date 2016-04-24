module AngularHelper

  def client_asset_path(filename)
    [(is_mobile_app_request? ? ENV['MOBILE_HOST'] : ''), :client, angular_asset_folder, filename].join('/')
  end

  private

  def is_mobile_app_request?
    request.env.fetch('HTTP_X_REQUESTED_WITH', '').match /cordova/
  end

  def angular_asset_folder
    Rails.env.production? ? Loomio::Version.current : :development
  end
end
