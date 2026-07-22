class RobotsController < ActionController::Base
  def show
    rule = ENV['ALLOW_ROBOTS'] ? 'Allow: /' : 'Disallow: /'
    render plain: "User-agent: *\n#{rule}\n"
  end
end
