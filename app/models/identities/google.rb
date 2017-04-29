class Identities::Google < Identities::Base
  include Identities::WithClient
  set_identity_type :google

  def fetch_user_info
    json         = client.fetch_user_info.json
    self.uid   ||= json.dig('metadata', 'sources', 0, 'id')
    self.name  ||= json.dig('names', 0, 'displayName')
    self.email ||= json.dig('emailAddresses', 0, 'value')
    self.logo  ||= json.dig('photos', 0, 'url')
  end
end
