module AngularHelper
  def client_asset_path(filename)
    filename = filename.to_s.gsub(".min", '') if Rails.env.development?
    [angular_asset_folder, filename].join('/')
  end

  private

  def angular_asset_folder
    version = Rails.env.production? ? Loomio::Version.current : :development
    "/client/#{version}"
  end
end
