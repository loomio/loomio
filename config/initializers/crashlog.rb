# Use this hook to configure how you want CrashLog to behave in your application.

# If you're using Bundler.setup instead of Bundler.require you will need to
# require CrashLog explicitly:
#
# require 'crashlog'

CrashLog.configure do |config|
  # ==> Authentication credentials
  # Enter your authentication credentials here. You can get these from the
  # 'Authentication' tab of your project in the CrashLog UI https://crashlog.io
  config.api_key  = ENV['CRASHLOG_API_KEY']
  config.secret   = ENV['CRASHLOG_SECRET']

  # ==> Ignored exceptions
  # By default we ignore:
  # - ActiveRecord::RecordNotFound,
  # - ActionController::RoutingError,
  # - ActionController::InvalidAuthenticityToken
  # - CGI::Session::CookieStore::TamperedWithCookie
  # - ActionController::UnknownAction
  # - AbstractController::ActionNotFound
  # - Mongoid::Errors::DocumentNotFound
  #
  # Generally most of these result in a 404 being sent back to the client,
  # as such they can create a lot of noise.
  #
  # To disable any of them uncomment and update this line:
  # config.ignore -= %w(ActionController::RoutingError)
  # or, don't ignore anything:
  # config.ignore = []

  # ==> Release stages
  # Configure the stages that you can to capture exceptions in. By default
  # we only activate in production and staging.
  #
  # When your application starts it will set the current stage to the name
  # of the current environment.
  #
  # Add another stage:
  # config.release_stages << 'integration'

  # ==> HTTP Adapter
  # Change adapter used to talk to CrashLog collection endpoints.
  # Available options:
  #
  # - :test                 - Test adapter, used for running tests.
  # - :net_http             - (Default) Ruby Net::HTTP
  # - :net_http_persistent  - Ruby Net::HTTP in persistent mode
  # - :typhoeus             - High performance parallel HTTP adapter
  # - :patron               - Ruby HTTP client based on libcurl
  # - :em_synchrony         - Asynchronous EventMachine based adapter
  # - :em_http              - Pretty much the same of above.
  # - :excon                - The wonderful adapter used by Fog.
  # - :rack                 - Rack adapter
  # - :httpclient           - 'httpclient' gives something like the
  #                           functionality of libwww-perl (LWP) in Ruby
  #
  # config.adapter = :net_http

  # ==> Timeouts
  # Increase these if you experience connection issues.
  #
  # Timeout for connecting to CrashLog collector interface (in seconds)
  # config.http_open_timeout = 5
  #
  # Timeout for actually sending the exeption payload (in seconds)
  # config.http_read_timeout = 2

  # ==> Environment filters
  # Filters for filtering ENV[] which gets sent with each exception.
  # Refer to https://github.com/crashlog/crashlog/blob/master/lib/crash_log/configuration.rb
  #
  # config.environment_filters += [/SOMETHING_SECRET/]

  # ==> Backtrace filters
  # Standard backtrace filters (processed by every line)
  # config.backtrace_filters += lambda { |line| }

  # ==> JSON Engine
  # If you have trouble encoding or decoding, or you're using a specific JSON
  # engine in your app, set it here.
  #
  # We use MultiJson behind the scenes so any option available to MultiJson can
  # be set.
  # config.json_parser = :yajl

  # ==> SSL certificate chain
  # On some platforms the SSL implementation available to Ruby doesn't include
  # our SSL providers certificate in the default chain. Because of this we package
  # our own certificate chain and use if by default. If you want to use the
  # system chain, set this to false.
  # config.use_system_ssl_cert_chain = false

  # ==> Advanced options
  # Refer to https://github.com/crashlog/crashlog/blob/master/lib/crash_log/configuration.rb
end
