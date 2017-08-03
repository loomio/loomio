class InvitationSerializer < ActiveModel::Serializer
  include Routing

  embed :ids, include: true
  attributes :id, :group_id, :token, :name, :email, :recipient_email, :accepted_at, :cancelled_at, :created_at, :updated_at, :single_use, :url

  has_one :inviter, serializer: UserSerializer, root: :users

  def url
    invitation_url(token, default_url_options)
  end
end
