class DiscussionInviteAndNotifyWorker
  include Sidekiq::Worker

  def perform(event_id, user_ids, emails, notify_group)
    event = Events::NewDiscussion.find(event_id)
    event.actor.ability.authorize! :announce, event.eventable
    readers = DiscussionService.create_discussion_readers(event.eventable, event.actor, user_ids, emails)
    event.discussion_readers = readers
    event.notify_group = notify_group
    event.trigger!
  end
end
