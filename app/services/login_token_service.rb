class LoginTokenService
  def self.create(actor:)
    return unless actor.is_logged_in?
    UserMailer.delay(priority: 1).login(user: actor, token: actor.login_tokens.create)
    EventBus.broadcast('user_login', actor)
  end
end
