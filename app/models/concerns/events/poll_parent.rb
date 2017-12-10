module Events::PollParent
  include Events::LookupMissingParent
  
  def self.lookup_parent(eventable)
    eventable.poll.created_event
  end
end
