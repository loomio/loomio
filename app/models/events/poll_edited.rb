class Events::PollEdited < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions

  def self.publish!(version, actor)
    super version,
          user: actor,
          parent: version.created_event,
          discussion: version.item.discussion
  end

  def poll
    eventable.item
  end
   # so that Events::Notify::Mentions looks at the poll rather than the PaperTrail::Version
  alias :mentionable :poll
end
