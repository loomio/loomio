module Events::Notify::ThirdParty
  def trigger!
    super
    identities.map { |i| i.notify! self }
  end

  private

  def identities
    if announcement
      eventable.group.identities
    else
      Identities::Base.none
    end
  end
end
