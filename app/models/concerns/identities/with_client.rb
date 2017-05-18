module Identities::WithClient
  def notify!(event)
    client.post_content!(event)
  end

  def is_member_of?(community)
    client.is_member_of?(community.identifier, self.uid) if community.community_type == identity.identity_type
  end

  def fetch_user_info
    apply_user_info(client.fetch_user_info.json)
  end

  private

  def client
    @client ||= "Clients::#{identity_type.to_s.classify}".constantize.new(token: self.access_token)
  end
  
  # called by default immediately after an access token is obtained.
  # Define a method here to get some basic information about the user,
  # like name, email, profile image, etc
  def apply_user_info(payload)
    raise NotImplementedError.new
  end
end
