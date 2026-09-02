class MembershipSerializer < ApplicationSerializer
  attributes :id,
             :group_id,
             :user_id,
             :inviter_id,
             :volume_email,
             :volume_push,
             :admin,
             :delegate,
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
      Array(scope[:membership_email_group_ids]).include?(object.group_id)
    )
  end

  def include_volume_email?
    scope && object.user_id == scope[:current_user_id]
  end

  alias_method :include_volume_push?, :include_volume_email?
end
