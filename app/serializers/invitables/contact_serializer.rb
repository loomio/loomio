class Invitables::ContactSerializer < Invitables::BaseSerializer

  def subtitle
    "<#{object.email}>"
  end           

  def image
    "http://placehold.it/40x40"
  end

end
