class Identities::Facebook < Identities::Base
  set_identity_type :facebook

  def fetch_user_id
    self.uid ||= client.get("me") { |response| response['id'] }
  end

  def admin_groups
    client.get("#{self.uid}/groups") { |response| response['data'] }
  end
end
