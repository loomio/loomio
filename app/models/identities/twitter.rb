class Identities::Twitter < Identities::Base
  include Identities::WithClient
  set_identity_type :twitter

  def apply_user_info(payload)
    self.uid   ||= payload['id_str']
    self.name  ||= payload['name']
    self.email ||= payload['email']
    self.logo  ||= payload['profile_image_url_https']
  end
end
