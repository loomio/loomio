module Events::DiscussionParent
  include Events::LookupMissingParent

  def self.lookup_parent(eventable)
    eventable.discussion&.created_at
  end
end
