class RemovePollExpiredFromThreadsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low, retry: false

  def perform(poll_id)
    p = Poll.find(poll_id)
    count = Event.where(eventable: p, kind: 'poll_expired').where("discussion_id is not null").
          update_all(discussion_id: nil, sequence_id: nil, position: 0, position_key: nil)
    EventService.repair_thread(p.discussion_id) if count > 0
    puts "count: #{count}, poll_id: #{poll_id}, discussion_id: #{p.discussion_id}" 
  end
end
