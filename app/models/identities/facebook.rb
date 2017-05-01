class Identities::Facebook < Identities::Base
  include Identities::WithClient
  set_identity_type :facebook

  def fetch_user_info
    json = client.fetch_user_info.json
    self.uid  ||= json['id']
    self.name ||= json['name']
  end

  def fetch_user_avatar
    self.logo = client.fetch_user_avatar(self.uid).json
  end

  def admin_groups
    if permissions_response.success?
      client.fetch_admin_groups(self.uid)
    else
      permissions_response
    end
  end

  private

  def permissions_response
    @permission_response ||= client.fetch_permissions(self.uid)
  end
end
