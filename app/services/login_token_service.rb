class LoginTokenService
  def self.create(actor:, uri:)
    return unless actor.presence

    token = LoginToken.create!(redirect: (uri.path if uri&.host == ENV['CANONICAL_HOST']), user: actor)

    UserMailer.delay(priority: 1).login(user: actor, token: token)
    EventBus.broadcast('login_token_create', token, actor)
  end
end
