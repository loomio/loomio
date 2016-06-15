class InvitationSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :token, :recipient_name, :recipient_email, :accepted_at, :cancelled_at, :created_at, :updated_at, :single_use, :url
  attribute :invitable_id, key: :group_id

  has_one :group,         serializer: GroupSerializer, root: :groups
  has_one :inviter,       serializer: UserSerializer, root: :users

  def url
    invitation_url(token)
  end
end
