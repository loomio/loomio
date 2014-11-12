class InvitableSerializer < ActiveModel::Serializer
  attributes :name,
             :subtitle,
             :image 

  def subtitle
    case object
    when Group   then "Add all members (#{object.members.count})"
    when Contact then "<#{object.email}>"
    when User    then "I'm a user!"
    end
  end           

  def image
    case object
    when Group   then object.logo.try(:url, :original, false)
    when Contact then "http://placehold.it/40x40"
    when User    then object.avatar.try(:url, :original, false)
    end
  end

end
