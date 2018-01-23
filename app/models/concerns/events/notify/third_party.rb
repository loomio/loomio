module Events::Notify::ThirdParty
  def trigger!
    super
    eventable.group.identities.map { |i| i.notify! self } if eventable.group
  end
end
