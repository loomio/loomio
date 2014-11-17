class Invitables::GroupSerializer < Invitables::BaseSerializer

  def subtitle
    "Add all members (#{object.members.count})"
  end           

  def image
    object.logo.try(:url, :original, false)
  end

end
