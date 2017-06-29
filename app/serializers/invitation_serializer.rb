class InvitationSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :group_id, :token, :recipient_name, :recipient_email, :accepted_at, :cancelled_at, :created_at, :updated_at, :single_use, :url

  has_one :inviter,       serializer: UserSerializer, root: :users

  def url
    invitation_path(token)
  end
end
