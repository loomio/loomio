module Events::Notify::ThirdParty
  def trigger!
    super
    eventable.group.identities.find_by(id: custom_fields['identity_id']).notify!(self)
  end
end
