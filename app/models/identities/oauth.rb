class Identities::Oauth < Identities::Base
  include Identities::WithClient
  set_identity_type :oauth

  def apply_user_info(payload)
    self.uid    ||= payload.dig(ENV.fetch('OAUTH_ATTR_UID'))
    self.name   ||= payload.dig(ENV.fetch('OAUTH_ATTR_NAME'))
    self.email  ||= payload.dig(ENV.fetch('OAUTH_ATTR_EMAIL'))
  end
end
