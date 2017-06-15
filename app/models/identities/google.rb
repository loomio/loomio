class Identities::Google < Identities::Base
  include Identities::WithClient
  set_identity_type :google

  def apply_user_info(payload)
    self.uid   ||= payload.dig('metadata', 'sources', 0, 'id')
    self.name  ||= payload.dig('names', 0, 'displayName')
    self.email ||= payload.dig('emailAddresses', 0, 'value')
    self.logo  ||= payload.dig('photos', 0, 'url')
  end
end
