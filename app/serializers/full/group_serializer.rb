class Full::GroupSerializer < GroupSerializer
  has_one :slack_group_identity, serializer: GroupIdentitySerializer, root: :group_identities

  def slack_group_identity
    object.identity_for(:slack)
  end
end
