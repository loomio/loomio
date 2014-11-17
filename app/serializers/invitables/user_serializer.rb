class Invitables::UserSerializer < Invitables::BaseSerializer

  def subtitle
    "@#{object.username}"
  end           

  def image
    object.avatar_url
  end

end
