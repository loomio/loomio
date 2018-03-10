class Full::GroupSerializer < GroupSerializer
  attribute :complete
  has_one :slack_group_identity, serializer: GroupIdentitySerializer, root: :group_identities

  def complete
    true
  end

  def slack_group_identity
    object.identity_for(:slack)
  end
end
