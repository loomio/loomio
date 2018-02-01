class AnnouncementSerializer < ActiveModel::Serializer
  attributes :invitation_ids, :user_ids, :kind

  has_one :author, serializer: UserSerializer, root: :users
end
