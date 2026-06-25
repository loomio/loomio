RailsPulse.configure do |config|
  # ====================================================================================================
  #                                         GLOBAL CONFIGURATION
  # ====================================================================================================

  # Enable or disable Rails Pulse
  config.enabled = !Rails.env.test?

  # ====================================================================================================
  #                                               THRESHOLDS
  # ====================================================================================================
  # These thresholds are used to determine if a route, request, or query is slow, very slow, or critical.
  # Values are in milliseconds (ms). Adjust these based on your application's performance requirements.

  # Thresholds for an individual route
  config.route_thresholds = {
    slow:      500,
    very_slow: 1500,
    critical:  3000
  }

  # Thresholds for an individual request
  config.request_thresholds = {
    slow:      700,
    very_slow: 2000,
    critical:  4000
  }

  # Thresholds for an individual database query
  config.query_thresholds = {
    slow:      100,
    very_slow: 500,
    critical:  1000
  }

  # ====================================================================================================
  #                                        SERVICE LEVEL OBJECTIVES (SLO)
  # ====================================================================================================
  # Define Service Level Objectives to visualize performance targets on the dashboard.
  # These SLOs appear as dashed threshold lines on the performance charts, color-matched
  # to their percentile series (green for P95, blue for P99).
  #
  # SLO Configuration:
  #   :percentile - Must be 95 or 99 (binds to the matching chart series)
  #   :threshold  - Maximum acceptable response time in milliseconds

  # SLO for HTTP request response times (shown on Response Time Percentiles chart)
  # config.service_level_objectives = [
  #   { percentile: 95, threshold: 200 },
  #   { percentile: 99, threshold: 500 }
  # ]

  # SLO for database query execution times (shown on Query Performance chart)
  # Query SLOs should typically be 5-10x stricter than request SLOs
  # config.query_service_level_objectives = [
  #   { percentile: 95, threshold: 50 },
  #   { percentile: 99, threshold: 100 }
  # ]

  # ====================================================================================================
  #                                               FILTERING
  # ====================================================================================================

  # Asset Tracking Configuration
  # By default, Rails Pulse ignores asset requests (images, CSS, JS files) to focus on application performance.
  # Set track_assets to true if you want to monitor asset delivery performance.
  config.track_assets = false

  # Custom asset patterns to ignore (in addition to the built-in defaults)
  # Only applies when track_assets is false. Add patterns for app-specific asset paths.
  config.custom_asset_patterns = [
    # Example: ignore specific asset directories
    # %r{^/uploads/},
    # %r{^/media/},
    # "/special-assets/"
  ]

  # Rails Pulse Mount Path (optional)
  # If Rails Pulse is mounted at a custom path, specify it here to prevent
  # Rails Pulse from tracking its own requests. Leave as nil for default '/rails_pulse'.
  # Examples:
  #   config.mount_path = "/admin/monitoring"
  config.mount_path = "/admin/pulse"

  # Manual route filtering
  # Specify additional routes, requests, or queries to ignore from performance tracking.
  # Each array can include strings (exact matches) or regular expressions.
  #
  # Examples:
  #   config.ignored_routes   = ["/health_check", %r{^/admin}]
  #   config.ignored_requests = ["GET /status", %r{POST /api/v1/.*}]
  #   config.ignored_queries  = ["SELECT 1", %r{FROM \"schema_migrations\"}]

  config.ignored_routes   = []
  config.ignored_requests = []
  config.ignored_queries  = []

  # ====================================================================================================
  #                                                 TAGGING
  # ====================================================================================================
  # Define custom tags for categorizing routes, requests, and queries.
  # You can add any custom tags you want for filtering and organization.
  #
  # Tag names should be in present tense and describe the current state or category.
  # Examples of good tag names:
  #   - "critical" (for high-priority endpoints)
  #   - "experimental" (for routes under development)
  #   - "deprecated" (for routes being phased out)
  #   - "external" (for third-party API calls)
  #   - "background" (for async job-related operations)
  #   - "admin" (for administrative routes)
  #   - "public" (for public-facing routes)
  #
  # Example configuration:
  #   config.tags = ["ignored", "critical", "experimental", "deprecated", "external", "admin"]

  config.tags = [ "ignored", "critical", "experimental" ]

  # ====================================================================================================
  #                                            BACKGROUND JOBS
  # ====================================================================================================
  # Configure background job monitoring and tracking.
  # When enabled, Rails Pulse will track job executions, durations, failures, and retries.
  # Supports ActiveJob, Sidekiq, and Delayed Job.

  # Enable or disable background job tracking
  config.track_jobs = true

  # Per-adapter job tracking. Solid Queue is what Loomio uses; it's enabled by
  # default via auto-detection, but set explicitly here so it's discoverable.
  # Flip track_recurring to true to also record recurring.yml schedule entries.
  config.job_adapters = {
    solid_queue: { enabled: true, track_recurring: true }
  }

  # Thresholds for job execution times (in milliseconds)
  config.job_thresholds = {
    slow:      5_000,   # 5 seconds
    very_slow: 30_000,  # 30 seconds
    critical:  60_000   # 1 minute
  }

  # Job classes to ignore from tracking (by class name)
  # Examples:
  #   config.ignored_jobs = ["ActionMailer::MailDeliveryJob", "MyApp::HealthCheckJob"]
  config.ignored_jobs = []

  # Queue names to ignore from tracking
  # Examples:
  #   config.ignored_queues = ["low_priority", "mailers"]
  config.ignored_queues = []

  # Capture job arguments for debugging (may contain sensitive data)
  # Set to false in production to avoid storing potentially sensitive information
  config.capture_job_arguments = false

  # ====================================================================================================
  #                                            DATABASE CONFIGURATION
  # ====================================================================================================
  # Configure Rails Pulse to use a separate database for performance monitoring data.
  # This is optional but recommended for production applications to isolate performance
  # data from your main application database.
  #
  # Uncomment and configure one of the following patterns:

  # Option 1: Separate single database for Rails Pulse
  # config.connects_to = {
  #   database: { writing: :rails_pulse, reading: :rails_pulse }
  # }

  # Option 2: Primary/replica configuration for Rails Pulse
  # config.connects_to = {
  #   database: { writing: :rails_pulse_primary, reading: :rails_pulse_replica }
  # }

  # Don't forget to add the database configuration to config/database.yml:
  #
  # production:
  #   # ... your main database config ...
  #   rails_pulse:
  #     adapter: postgresql  # or mysql2, sqlite3
  #     database: myapp_rails_pulse_production
  #     username: rails_pulse_user
  #     password: <%= Rails.application.credentials.dig(:rails_pulse, :database_password) %>
  #     host: localhost
  #     pool: 5

  # ====================================================================================================
  #                                            AUTHENTICATION
  # ====================================================================================================
  # Configure authentication to secure access to the Rails Pulse dashboard.
  # Authentication is ENABLED BY DEFAULT in production environments for security.
  #
  # If no authentication method is configured, Rails Pulse will use HTTP Basic Auth
  # with credentials from RAILS_PULSE_USERNAME (default: 'admin') and RAILS_PULSE_PASSWORD
  # environment variables. Set RAILS_PULSE_PASSWORD to enable this fallback.
  #
  # Uncomment and configure one of the following patterns based on your authentication system:

  # Access is gated by the admin_session_constraint in config/routes.rb (same as
  # MissionControl::Jobs at /admin/jobs), which 404s non-admins before they reach
  # the engine. So Rails Pulse's own auth layer (and its HTTP Basic fallback) is
  # disabled here to avoid a second prompt.
  config.authentication_enabled = false

  # Enable/disable authentication (enabled by default in production)
  # config.authentication_enabled = Rails.env.production?

  # Where to redirect unauthorized users
  # config.authentication_redirect_path = "/"

  # Custom authentication method - choose one of the examples below:

  # Example 1: Devise with admin role check
  # config.authentication_method = proc {
  #   unless user_signed_in? && current_user.admin?
  #     redirect_to main_app.root_path, alert: "Access denied"
  #   end
  # }

  # Example 2: Custom session-based authentication
  # config.authentication_method = proc {
  #   unless session[:user_id] && User.find_by(id: session[:user_id])&.admin?
  #     redirect_to main_app.login_path, alert: "Please log in as an admin"
  #   end
  # }

  # Example 3: Warden authentication
  # config.authentication_method = proc {
  #   warden.authenticate!(:scope => :admin)
  # }

  # Example 4: Basic HTTP authentication
  # config.authentication_method = proc {
  #   authenticate_or_request_with_http_basic do |username, password|
  #     username == ENV['RAILS_PULSE_USERNAME'] && password == ENV['RAILS_PULSE_PASSWORD']
  #   end
  # }

  # Example 5: Custom authorization check
  # config.authentication_method = proc {
  #   current_user = User.find_by(id: session[:user_id])
  #   unless current_user&.can_access_rails_pulse?
  #     render plain: "Forbidden", status: :forbidden
  #   end
  # }

  # ====================================================================================================
  #                                             DEPLOYMENT TRACKING
  # ====================================================================================================
  # Record deployments to display vertical marker lines on performance charts, making it easy
  # to correlate performance changes with specific releases.
  #
  # API token for the POST /rails_pulse/deployments endpoint.
  # When set, requests must include an `X-Rails-Pulse-Token` header matching this value.
  # When nil, the endpoint falls back to the standard dashboard authentication.
  #
  # Set this in your CI/CD pipeline and store the value in credentials or an environment variable:
  #   config.deployment_api_token = Rails.application.credentials.dig(:rails_pulse, :deployment_api_token)
  #   config.deployment_api_token = ENV["RAILS_PULSE_DEPLOYMENT_TOKEN"]
  #
  # Record a deployment from your CI/CD pipeline:
  #   curl -X POST https://yourapp.com/rails_pulse/deployments \
  #     -H "X-Rails-Pulse-Token: $RAILS_PULSE_DEPLOYMENT_TOKEN" \
  #     -H "Content-Type: application/json" \
  #     -d '{"deployment": {"revision": "abc1234", "metadata": {"environment": "production"}}}'
  #
  # Or use the rake task for simple shell-based deploys:
  #   rake rails_pulse:record_deployment[abc1234]

  # config.deployment_api_token = ENV["RAILS_PULSE_DEPLOYMENT_TOKEN"]

  # ====================================================================================================
  #                                               DATA CLEANUP
  # ====================================================================================================
  # Configure automatic cleanup of old performance data to manage database size.
  # Rails Pulse provides two cleanup mechanisms that work together:
  #
  # 1. Time-based cleanup: Delete records older than the retention period
  # 2. Count-based cleanup: Keep only the specified number of records per table
  #
  # Cleanup order respects foreign key constraints:
  # operations → requests → queries/routes

  # Enable or disable automatic data cleanup
  config.archiving_enabled = true

  # Time-based retention - delete records older than this period
  config.full_retention_period = 2.weeks

  # Count-based retention - maximum records to keep per table
  # After time-based cleanup, if tables still exceed these limits,
  # the oldest remaining records will be deleted to stay under the limit
  config.max_table_records = {
    rails_pulse_requests: 10000,    # HTTP requests (moderate volume)
    rails_pulse_operations: 50000,  # Operations within requests (high volume)
    rails_pulse_routes: 1000,       # Unique routes (low volume)
    rails_pulse_queries: 500        # Normalized SQL queries (low volume)
  }
end
