class SpamRulesMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Keep the orchestrator's health probe independent of operator IP bans.
    return @app.call(env) if env['PATH_INFO'] == '/up'
    SpamRules.with_context do
      request = Rack::Attack::Request.new(env)
      action = if request.post? && %w[/api/v1/registrations /api/v1/trials].include?(request.path)
        'signup'
      elsif request.post? && %w[/api/v1/sessions /api/v1/passkey_credentials/authenticate /api/v1/mobile/token].include?(request.path)
        'sign_in'
      else
        'access'
      end
      if SpamRules.blocked?(request.remote_ip, target: :ip, action: action)
        api = request.path.start_with?('/api/') || request.get_header('HTTP_ACCEPT').to_s.include?('application/json')
        type = api ? 'application/json' : 'text/plain; charset=utf-8'
        message = I18n.t('errors.403.title')
        body = api ? JSON.generate(error: message) : message
        [ 403, { 'content-type' => type, 'cache-control' => 'no-store' }, [ body ] ]
      else
        @app.call(env)
      end
    end
  end
end
