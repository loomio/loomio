class AuthorSerializer < ActiveModel::Serializer
  attributes :id, :name, :avatar_initials, :avatar_kind, :avatar_url

  def avatar_url
    object.avatar_url('med-large')
  end
end
