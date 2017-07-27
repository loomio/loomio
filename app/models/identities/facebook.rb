class Identities::Facebook < Identities::Base
  include Identities::WithClient
  set_identity_type :facebook

  def apply_user_info(payload)
    self.uid   ||= payload['id']
    self.name  ||= payload['name']
    self.email ||= payload['email']
  end

  def fetch_user_avatar
    self.logo = client.fetch_user_avatar(self.uid).json
  end

  def admin_groups
    if permissions_response.json['error'].blank?
      client.fetch_admin_groups(self.uid)
    else
      permissions_response
    end
  end

  private

  def publish_events
    []
  end

  def permissions_response
    @permission_response ||= client.fetch_permissions(self.uid)
  end
end
