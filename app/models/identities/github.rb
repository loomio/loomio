class Identities::Github < Identities::Base
  include Identities::WithClient
  set_identity_type :github

  def fetch_user_info
    json = client.fetch_user_info.json
    byebug
    self.uid   ||= json['id']
    self.name  ||= json['name']
    self.email ||= json['email']
    self.logo  ||= json['avatar_url']
  end
end
