module AngularHelper

  def client_asset_path(filename)
    [(is_mobile_app_request? ? ENV['MOBILE_HOST'] : ''), :client, angular_asset_folder, filename].join('/')
  end

  private

  def is_mobile_app_request?
    puts "HTTP_X_REQUESTED_WITH: #{request.env["HTTP_X_REQUESTED_WITH"]}"
    ENV['MOBILE_APP_ID'].present? && ENV['MOBILE_APP_ID'] == request.env['HTTP_X_REQUESTED_WITH']
  end

  def angular_asset_folder
    Rails.env.production? ? Loomio::Version.current : :development
  end
end
