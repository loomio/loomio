module Events::Notify::ThirdParty
  def trigger!
    super
    eventable.group.identities.map {|i| i.notify!(self) }
  end
end
