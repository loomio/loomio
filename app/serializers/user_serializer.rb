class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :username, :avatar_initials, :avatar_kind, :avatar_url

  def avatar_url
    object.avatar_url('med-large')
  end
end
