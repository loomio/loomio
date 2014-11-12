class InvitableSerializer < ActiveModel::Serializer
  attributes :name,
             :is_loomio_member,
             :subtitle,
             :image,
             :recipients

  def is_loomio_member
    case object
    when Group, User then true
    when Contact then false
    end
  end

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
    when User    then object.avatar_url
    end
  end

  def recipients
    case object
    when Group then object.members.map(&:email)
    when Contact, User then [object.email]
    end
  end

end
