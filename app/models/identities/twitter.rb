class Identities::Twitter < Identities::Base
  include Identities::WithClient
  set_identity_type :twitter

  def fetch_user_info
    json = client.fetch_user_info.json
    self.uid   ||= json['id_str']
    self.name  ||= json['name']
    self.email ||= json['email']
    self.logo  ||= json['profile_image_url_https']
  end
end
