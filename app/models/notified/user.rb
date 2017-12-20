class Notified::User < Notified::Base
  def id
    model.id
  end

  def title
    model.name
  end

  def subtitle
    model.username
  end

  def icon_url
    model.avatar_url(:small)
  end

  def notified_ids
    Array(model.id)
  end

  def avatar_initials
    model.avatar_initials
  end
end
