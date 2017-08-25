module AngularHelper
  def client_asset_path(filename)
    filename = filename.to_s.gsub(".min", '') if Rails.env.development?
    ['', :client, angular_asset_folder, filename].join('/')
  end

  private

  def angular_asset_folder
    Rails.env.production? ? Loomio::Version.current : :development
  end
end
