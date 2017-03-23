class Identities::Facebook < Identities::Base
  set_identity_type :facebook

  def fetch_user_info
    me_response = client.fetch_user_info
    self.uid  ||= me_response['id']
    self.name ||= me_response['name']
  end

  def fetch_user_avatar
    self.logo = client.fetch_user_avatar(self.uid)
  end

  def admin_groups
    client.fetch_admin_groups(self.uid)
  end

  def is_member_of?(community)
    client.is_member_of?(community.identifier, self.uid)
  end
end
