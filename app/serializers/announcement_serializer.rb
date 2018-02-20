class AnnouncementSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :invitation_ids, :user_ids, :kind, :created_at

  has_one :author, serializer: UserSerializer, root: :users
  has_one :event, serializer: Simple::EventSerializer, root: :events
  has_many :users, serializer: Simple::UserSerializer, root: :users
  has_many :invitations, serializer: InvitationSerializer, root: :invitations

  def users
    from_scope(:users).select { |user| user_ids.include?(user.id) }
  end

  def invitations
    from_scope(:invitations).select { |invitation| invitation_ids.include?(invitation.id) }
  end

  private

  def from_scope(field)
    Array(Hash(scope)[field])
  end
end
