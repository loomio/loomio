class LoginTokenService
  def self.create(actor:, uri:)
    return unless actor.presence

    token = LoginToken.create!(redirect: (uri.path if uri&.host == ENV['CANONICAL_HOST']), user: actor)

    UserMailer.login(actor.id, token.id).deliver_now
    token
  end
end
