Notified::User = Struct.new(:user) do
  alias :read_attribute_for_serialization :send

  def id
    user.id
  end

  def title
    user.name
  end

  def subtitle
    :"@#{user.username}"
  end

  def icon_url
    user.avatar_url(:small)
  end
end
