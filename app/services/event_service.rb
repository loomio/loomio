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

  def self.restore_missing_new_discussion_events
    # SELECT * FROM discussions outer join events ON events.kind = "new_discussion" and events.eventable_id = discussions.id where events.id is null
    #
    # each of these insert new discussion event
    # set parent_id on all new_comment events with discussion_id in above ids
    # reorder position on items in each discussion
  end

  def self.restore_missing_new_comment_events
    # find all the missing new comment events
    # update all the new_comment events so the parent is their new_discussion event
    # rails update the last comment in each discussion so position is correct.
    #
    # record all discussion ids concerned
    # recalc child_count and position for it's items
  end

  def self.reset_new_comment_depth
    # all non reply comments are depth 1
    # others need to be calculated
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

      # the following is what we would do if it were not so slow
      # event.update_attributes(user: poll.author,
      #                         kind: "poll_created",
      #                         parent: poll.discussion.created_event,
      #                         eventable: poll)

      parent_event = poll.discussion.created_event || begin
        e = Events::NewDiscussion.new kind: 'new_discussion',
                                 user_id: poll.discussion.author.id,
                                 announcement: false,
                                 eventable_id: poll.discussion.id,
                                 eventable_type: "Discussion",
                                 depth: 0,
                                 created_at: poll.discussion.created_at
        Events::NewDiscussion.import [e] # so we dont trigger emails etc
        Event.where(kind: "new_comment",
                    discussion_id: poll.discussion.id).each do |new_comment_event|
          new_comment_event.update(parent: e)
        end
        e
      end

      Event.where(id: event.id).update_all(user_id: poll.author_id,
                                           kind: "poll_created",
                                           parent_id: poll.discussion.created_event,
                                           eventable_id: poll.id,
                                           eventable_type: "Poll",
                                           depth: 1)
      parent_event.update_child_count
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
      Event.where(id: event.id).update_all(user_id: stance.participant_id,
                                           eventable_type: "Stance",
                                           eventable_id: stance.id,
                                           parent_id: stance.poll.created_event,
                                           kind: "stance_created",
                                           depth: 2,
                                           child_count: 0)
      event.parent.update_chlid_count
      # event.update_attributes(user: stance.author,
      #                         eventable: stance,
      #                         parent: stance.poll.created_event,
      #                         kind: "stance_created")
    end
  end

  # migrate motion_outcome_created_events
  # create missing outcome created events.
  # migrate motion_closed -> poll_expired
  # migrate motion_closed_by_user to poll_closed_by_user
end
