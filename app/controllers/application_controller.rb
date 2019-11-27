class ApplicationController < ActionController::Base
  include LocalesHelper
  include AngularHelper
  include ProtectedFromForgery
  include ErrorRescueHelper
  include CurrentUserHelper
  include ForceSslHelper
  include SentryRavenHelper
  include PrettyUrlHelper

  around_action :process_time_zone          # LocalesHelper
  around_action :use_preferred_locale       # LocalesHelper
  before_action :set_last_seen_at           # CurrentUserHelper
  before_action :handle_pending_memberships # PendingActionsHelper
  before_action :set_raven_context

  helper_method :current_user
  helper_method :current_version
  helper_method :client_asset_path
  helper_method :bundle_asset_path
  helper_method :supported_locales

  def index
    expires_now
    prevent_caching
    if should_redirect_to_browser_upgrade?
      render file: 'public/417.html', status: 417
    else
      if ENV['TASK'] == 'e2e' or params['old_client'] or (current_user.is_logged_in? && current_user.experiences['old_client'])
        render 'application/index', layout: false
      else
        template = File.read(Rails.root.join('public/client/vue/index.html'))
        template.sub! '<loomio_metadata_tags>', '<%= render "application/social_metadata" %>'
        render inline: template, layout: false
      end
    end
  end

  def crowdfunding
    render layout: 'basic'
  end

  def ok
    head :ok
  end

  def redirect_to(url, opts = {})
    return super unless url.is_a? String # GK: for now this override only covers cases where a string has been passed in, so it does not cover cases of a Hash or a Record being passed in
    host = URI(url).host
    if ENV['USE_VUE'] && Rails.env.development? && host == "localhost"
      path = URI(url).path
      query = URI(url).query ? "?#{URI(url).query}" : ""
      super "http://localhost:8080#{path}#{query}"
    else
      super
    end
  end

  protected
  def prevent_caching
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate' # HTTP 1.1.
    response.headers['Pragma'] = 'no-cache' # HTTP 1.0.
    response.headers['Expires'] = '0' # Proxies.
  end

  private

  def should_redirect_to_browser_upgrade?
    !params[:skip_browser_upgrade] &&
    !@skip_browser_upgrade &&
    !request.params['old_client'] &&
    !request.xhr? &&
    (browser.ie? ||
    (browser.chrome?  && browser.version.to_i < 65) ||
    (browser.firefox? && !browser.platform.ios? && browser.version.to_i < 55) ||
    (browser.safari?  && browser.version.to_i < 12) ||
    (browser.edge?    && browser.version.to_i < 17))
  end
end
