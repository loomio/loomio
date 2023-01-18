class Identities::Oauth < Identities::Base
  include Identities::WithClient
  set_identity_type :oauth

  def apply_user_info(payload)
    # need to make this dynamic based on ENVs with some defaults
    payload = payload['ocs']['data']
    self.uid    ||= payload['id']
    self.name   ||= payload['id']
    self.email  ||= payload['email']
  end
end
