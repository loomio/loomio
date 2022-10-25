class UserWithEmailSerializer < UserSerializer
  def include_email?
    true
  end
end
