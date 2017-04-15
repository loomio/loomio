module Identities::WithClient
  def notify!(event)
    client.post_content!(event)
  end

  def is_member_of?(community)
    client.is_member_of?(community.identifier, self.uid) if community.community_type == identity.identity_type
  end

  private

  def client
    @client ||= "Clients::#{identity_type.to_s.classify}".constantize.new(token: self.access_token)
  end
end
