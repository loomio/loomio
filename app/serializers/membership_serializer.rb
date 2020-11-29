class MembershipSerializer < ApplicationSerializer
  attributes :id,
             :group_id,
             :user_id,
             :inviter_id,
             :volume,
             :admin,
             :experiences,
             :title,
             :created_at,
             :accepted_at

  has_one :group, serializer: GroupSerializer, root: :groups
  has_one :user, serializer: UserSerializer, root: :users
  has_one :inviter, serializer: AuthorSerializer, root: :users
end
