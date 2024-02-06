class MemberEmailAliasSerializer < ApplicationSerializer
  attributes :id,
             :email,
             :group_id,
             :user_id,
             :author_id,
             :created_at


  has_one :user, serializer: AuthorSerializer, root: :users, key: :user_id
  has_one :author, serializer: AuthorSerializer, root: :users

  def user_email
    (cache_fetch(:users_by_id, object.user_id) { object.user }).email
  end

  def include_user_email?
    true
  end
end
