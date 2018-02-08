module SentryRavenHelper
  def set_raven_context
    Raven.user_context(id: current_user.id) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
