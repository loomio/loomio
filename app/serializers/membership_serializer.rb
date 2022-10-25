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
  has_one :user_without_email, serializer: UserSerializer, root: :users, key: :user_id
  has_one :user_with_email, serializer: UserWithEmailSerializer, root: :users, key: :user_id
  has_one :inviter, serializer: AuthorSerializer, root: :users

  def include_user_without_email?
    !include_user_with_email?
  end

  def include_user_with_email?
    scope && (
      object.user_id == scope[:current_user_id] ||
      object.inviter_id == scope[:current_user_id] ||
      scope[:current_user_is_admin]
    )
  end

  def user_without_email
    user
  end

  def user_with_email
    user
  end

end
