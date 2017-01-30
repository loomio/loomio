class Events::PollClosingSoon < Event
  def self.publish!(poll)
    create(kind: "poll_closing_soon",
           eventable: poll).tap { |e| EventBus.broadcast('poll_closing_soon_event', e) }
  end
end
