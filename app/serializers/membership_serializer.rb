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
             :accepted_at,
             :user_email

  has_one :group, serializer: GroupSerializer, root: :groups
  has_one :user, serializer: UserSerializer, root: :users, key: :user_id
  has_one :inviter, serializer: AuthorSerializer, root: :users

  def user_email
    (cache_fetch(:users_by_id, object.user_id) { object.user }).email
  end

  def include_user_email?
    scope && (
      object.inviter_id == scope[:current_user_id] ||
      scope[:current_user_is_admin]
    )
  end
end
