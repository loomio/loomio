class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :username, :avatar_initials, :avatar_kind, :avatar_url, :profile_url, :gravatar_md5
  attributes :dashboard_sort, :dashboard_filter

  def is_current_user?
    object == current_user
  end

  alias :include_dashboard_sort :is_current_user?
  alias :include_dashboard_filter :is_current_user?

  def gravatar_md5
    Digest::MD5.hexdigest(object.email.to_s.downcase) if object.avatar_kind == "gravatar"
  end

  def avatar_url
    object.avatar_url('medium')
  end

  def profile_url
    object.avatar_url :large
  end
end
