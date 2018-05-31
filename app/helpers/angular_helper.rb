module AngularHelper
  def current_version
    Rails.env.production? ? Loomio::Version.current : :development
  end

  def bundle_asset_path(filename)
    [angular_bundle_host, client_asset_path(filename)].compact.join('/')
  end

  def client_asset_path(filename)
    filename = filename.to_s.gsub(".min", '') if Rails.env.development?
    [angular_asset_folder, filename].join('/')
  end

  private

  def angular_asset_folder
    [:client, current_version].join('/')
  end

  def angular_bundle_host
    :"http://#{request.host}:4002" if Rails.env.development?
  end
end
