class Identities::Facebook < Identities::Base
  set_identity_type :facebook
  set_custom_fields :facebook_user_id

  def fetch_user_id
    self.facebook_user_id ||= client.get("me") { |response| response['id'] }
  end

  def fetch_admin_groups
    client.get("#{facebook_user_id}/groups") { |response| response }
  end
end
