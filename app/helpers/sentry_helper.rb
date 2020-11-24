module SentryHelper
  def set_sentry_context
    Sentry.configure_scope do |scope|
      scope.set_user(id: current_user.id)
      scope.set_tags(email: current_user.email, name: current_user.name)
      # scope.set_extra(params: params.to_unsafe_h, url: request.url)
    end
  end
end
