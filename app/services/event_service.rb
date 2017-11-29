class EventService
  def self.remove_from_thread(event:, actor:)
    actor.ability.authorize! :remove_from_thread, event
    discussion = event.discussion
    event.update(discussion_id: nil)
    discussion.thread_item_destroyed!
    event
  end

  def self.readd_to_thread(kind:)
    Event.where(kind: kind, discussion_id: nil).where("sequence_id is not null").find_each do |event|
      next unless event.eventable

      if Event.exists?(sequence_id: event.sequence_id, discussion_id: event.eventable.discussion_id)
        Event.where(discussion_id: event.eventable.discussion_id)
             .where("sequence_id >= ?", event.sequence_id)
             .order(sequence_id: :desc)
             .each { |event| event.increment!(:sequence_id) }
      end

      event.update_attribute(:discussion_id, event.eventable.discussion_id)
      event.reload.discussion.update_sequence_info!
    end
  end

  # new_motion -> poll_created
  # new_vote   -> stance_created
  # motion_edited -> poll_edited
  # motion_outcome_created -> outcome_created
  # motion_closed          -> poll_expired
  # motion_closed_by_user  -> poll_closed_by_user
  #
  # delete motion_description_edited, motion_name_edited, motion_close_date_edited, discussion_title_edited, discussion_description_edited
  # new_motion, new_vote, motion_edited, motion_outcome_created all have sequence ids
  # some motion closed and motion_closed_by_user do not, some do.
  # new_motion has no user_id

  def self.around_about(time)
    (time - 1.second)..(time + 1.second)
  end

  def self.migrate_new_motion_events
    # 1 second per record
    # takes hours.
    # migrate new_motion -> poll_created
    # we know that all new_motion events
    # have sequence_id
    # have discussion_id
    # have no user_id
    total = Event.where(kind: "new_motion").count
    try = 0
    hit = 0
    Event.where(kind: "new_motion").find_each do |event|
      puts "total: #{total} try: #{try} hit: #{hit}"
      try += 1
      poll = Poll.where(discussion_id: event.discussion_id,
                        created_at: around_about(event.created_at)).first
      next unless poll
      hit += 1
      event.update_attributes(user: poll.author,
                              kind: "poll_created",
                              parent: poll.discussion.created_event,
                              eventable: poll)
    end
  end

  def self.migrate_new_vote_events
    # 2 seconds per record
    # migrate new_vote -> stance_created
    # they don't have user_id
    # they all have sequence_id and discussion_id
    # they have incorrect eventable
    total = Event.where(kind: "new_vote").count
    try = 0
    hit = 0
    Event.where(kind: "new_vote").find_each do |event|
      puts "total: #{total} try: #{try} hit: #{hit}"
      try += 1
      stance = Stance.joins(poll: :discussion).where("discussions.id" => event.discussion_id,
                                                     created_at:         around_about(event.created_at)).first
      next unless stance
      hit += 1
      event.update_attributes(user: stance.author,
                              eventable: stance,
                              parent: stance.poll.created_event,
                              kind: "stance_created")
    end
  end

end
