class Identities::Nextcloud < Identities::Base
  include Identities::WithClient
  set_identity_type :nextcloud

  def apply_user_info(payload)
    payload = payload['ocs']['data']
    self.uid    ||= payload['id']
    self.name   ||= payload['id']
    self.email  ||= payload['email']
  end
end
