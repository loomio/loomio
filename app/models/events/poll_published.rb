class Events::PollPublished < Event
  include Events::VisitorEvent

  def self.publish!(poll, actor, custom_fields)
    create(kind: "poll_published",
           user: actor,
           custom_fields: custom_fields,
           eventable: poll).tap { |e| EventBus.broadcast('poll_published_event', e) }
  end

  private

  def communities
    Communities::Base.where(id: custom_fields[:community_id])
  end
end
