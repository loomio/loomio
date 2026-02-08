class ApplicationController < ActionController::Base
  layout false

  include LocalesHelper
  include ProtectedFromForgery
  include CurrentUserHelper
  include SentryHelper
  include PrettyUrlHelper
  include LoadAndAuthorize
  include EmailHelper
  include ApplicationHelper
  helper :email
  helper :formatted_date

  around_action :process_time_zone          # LocalesHelper
  around_action :use_preferred_locale       # LocalesHelper
  before_action :deny_spam_users            # CurrentUserHelper
  before_action :set_last_seen_at           # CurrentUserHelper
  before_action :handle_pending_actions     # PendingActionsHelper
  before_action :set_sentry_context

  helper_method :current_user
  helper_method :current_version
  helper_method :bundle_asset_path
  helper_method :supported_locales

  skip_before_action :verify_authenticity_token, only: :bug_tunnel
  caches_page :sitemap

  rescue_from(ActionController::UnknownFormat) do
    respond_with_error 404
  end

  rescue_from(ActionView::MissingTemplate) do |exception|
    raise exception unless %w[txt text gif png].include?(params[:format])
  end

  rescue_from(ActiveRecord::RecordNotFound) do
    respond_with_error 404
  end

  rescue_from(Membership::InvitationAlreadyUsed) do |exception|
    session.delete(:pending_membership_token)
    if current_user.ability.can?(:show, exception.membership.group)
      redirect_to polymorphic_path(exception.membership.group) || dashboard_path
    else
      respond_with_error 400, t("invitation.invitation_already_used")
    end
  end

  rescue_from(CanCan::AccessDenied) do |exception|
    if current_user.is_logged_in?
      flash[:error] = t("error.access_denied")
      redirect_to dashboard_path
    else
      authenticate_user!
    end
  end

  def sitemap
    @entries = []
    return unless AppConfig.app_features[:sitemap]

    Group.published.where(is_visible_to_public: true).each do |g|
      @entries << [url_for(g), g.updated_at.to_date.iso8601]
    end

    Discussion.visible_to_public.joins(:group).where('groups.archived_at is null').each do |d|
      @entries << [url_for(d), d.last_activity_at.to_date.iso8601]
    end
  end

  def index
    boot_app
  end

  def show
    resource = ModelLocator.new(resource_name, params).locate!
    @recipient = current_user
    if current_user.can? :show, resource
      assign_resource
      @pagination = pagination_params
      respond_to do |format|
        format.html
        format.xml
      end
    else
      respond_with_error 403
    end
  end

  def crowdfunding
    render Views::Application::Crowdfunding.new
  end

  def brand
    render Views::Application::Brand.new
  end

  def bug_tunnel
    raise "no sentry dsn" unless ENV['SENTRY_PUBLIC_DSN']

    uri = URI(ENV['SENTRY_PUBLIC_DSN'])
    known_host = uri.host
    known_project_id = uri.path.tr('/', '')

    envelope = request.body.read
    piece = envelope.split("\n").first
    header = JSON.parse(piece)
    dsn = URI.parse(header['dsn'])
    project_id = dsn.path.tr('/', '')

    raise "Invalid sentry hostname: #{dsn.hostname}" if dsn.hostname != known_host
    raise "Invalid sentry project id: #{project_id}" if project_id != known_project_id

    upstream_sentry_url = "https://#{known_host}/api/#{known_project_id}/envelope/"
    Net::HTTP.post(URI(upstream_sentry_url), envelope)

    head(:ok)
  rescue => e
    Rails.logger.error('error tunneling to sentry')
  end

  def ok
    head :ok
  end

  protected

  def respond_with_error(status, message = nil)
    @title = t("errors.#{status}.title")
    @body = message || t("errors.#{status}.body")
    @metadata = {title: @title, description: @body }
    respond_to do |format|
      format.html { boot_app(status: status) }
      format.json { render json: { error: message || @title }, root: false, status: status }
      format.xml { render xml: { error: message || @title }, status: status }
    end
  end

  def pagination_params
    default_limit = params[:export] ? 2000 : 10
    { limit: params.fetch(:limit, default_limit).to_i, offset: params.fetch(:offset, 0).to_i }
  end

  def prevent_caching
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate' # HTTP 1.1.
    response.headers['Pragma'] = 'no-cache' # HTTP 1.0.
    response.headers['Expires'] = '0' # Proxies.
  end

  private

  def boot_app(status: 200)
    expires_now
    prevent_caching
    render Views::BootApp.new(
      metadata: metadata, export: !!params[:export], bot: browser.bot?
    ), status: status
  end
end
