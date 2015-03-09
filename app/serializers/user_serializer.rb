class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :username, :avatar_initials, :avatar_kind, :avatar_url, :profile_url, :selected_locale, :detected_locale

  def avatar_url
    object.avatar_url('medium')
  end

  def profile_url
    object.avatar_url :large
  end
end
