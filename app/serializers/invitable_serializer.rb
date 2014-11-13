class InvitableSerializer < ActiveModel::Serializer
  attributes :id,
             :type,
             :name,
             :subtitle,
             :image

  def type
    object.class.to_s
  end

  def subtitle
    case object
    when Group   then "Add all members (#{object.members.count})"
    when Contact then "<#{object.email}>"
    when User    then "@#{object.username}"
    end
  end           

  def image
    case object
    when Group   then object.logo.try(:url, :original, false)
    when Contact then "http://placehold.it/40x40"
    when User    then object.avatar_url
    end
  end

end
