Notified::Invitation = Struct.new(:email) do
  alias :read_attribute_for_serialization :send

  def title
    email.scan(ReceivedEmail::EMAIL_REGEX)
  end
  alias :id :title

  def subtitle
    ""
  end

  def icon_url
    "wark"
  end
end
