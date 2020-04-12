module Events::Notify::ThirdParty
  def trigger!
    super
    if eventable.group
      eventable.group.identities.map { |i| i.notify! self }
      eventable.group.webhooks.each { |w| w.publish!(self) }
    end
  end
end
