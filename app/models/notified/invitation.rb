Notified::Invitation = Struct.new(:email) do
  alias :read_attribute_for_serialization :send

  def title
    email
  end
  alias :id :title

  def subtitle
    nil
  end

  def icon_url
    nil
  end
end
