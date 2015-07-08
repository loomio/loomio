class CurrentUserSerializer < UserSerializer
  attributes :email

  def include_gravatar_md5?
    true
  end
end
