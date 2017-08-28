Notified::Group = Struct.new(:group) do
  alias :read_attribute_for_serialization :send

  def id
    group.id
  end

  def title
    group.full_name
  end

  def subtitle
    "(X members)"
  end

  def icon_url
    group.logo.presence&.url(:card) || '/img/default-logo-medium.png'
  end
end
