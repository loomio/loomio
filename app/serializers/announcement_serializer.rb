class AnnouncementSerializer < ActiveModel::Serializer
  attributes :invitation_ids, :user_ids, :kind

  has_one :author, serializer: UserSerializer, root: :users
  has_one :event, serializer: Simple::EventSerializer, root: :events
end
