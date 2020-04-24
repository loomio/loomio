class ReactionSerializer < ApplicationSerializer
  attributes :id, :reaction, :reactable_id, :reactable_type, :user_id
  has_one :user, serializer: AuthorSerializer, root: :users
end
