class Identities::Github < Identities::Base
  include Identities::WithClient
  set_identity_type :github

  def apply_user_info(payload)
    self.uid   ||= payload['id']
    self.name  ||= payload['name']
    self.email ||= payload['email']
    self.logo  ||= payload['avatar_url']
  end
end
