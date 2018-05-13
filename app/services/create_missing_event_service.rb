module CreateMissingEventService
  def self.new_comment(comment)
    # we can't actually do this easily, and don't need to
    # res = Event.import [Event.new(kind: 'new_comment',
    #                               user_id: comment.author_id,
    #                               discussion_id: comment.discussion_id,
    #                               parent_id: comment.parent_event,
    #                               depth: 1,
    #                               eventable_id: comment.id,
    #                               eventable_type: "Comment",
    #                               created_at: comment.created_at)]
    #
    # event = Events::NewComment.find(res.ids.first.to_i)
  end

  def self.new_discussion(discussion)
    res = Event.import [Event.new(kind: 'new_discussion',
                            user_id: discussion.author_id,
                            eventable_id: discussion.id,
                            eventable_type: "Discussion",
                            created_at: discussion.created_at)]

    event = Events::NewDiscussion.find(res.ids.first.to_i)

    # fix depth and parent_id for existing new_comment events
    # new_comment with no parent = depth 1
    non_reply_comments = discussion.comments.where(parent_id: nil)

    discussion.items.where(kind: "new_comment",
                           eventable_id: non_reply_comments.pluck(:id)).
                     update_all(depth: 1, parent_id: event.id)

    # new_comments that are replies
    reply_comments = discussion.comments.where.not(parent_id: nil)
    discussion.items.where(kind: "new_comment",
                           eventable_id: reply_comments.pluck(:id)).each do |event|
      event.update(parent: event.eventable.parent_event, depth: 2)
    end

    # ensure all poll_created, stance_created events exist
    discussion.polls.order(:created_at).each(&:created_event)
    event
  end

  def self.poll_created(poll)
    Event.where(kind: "new_motion", discussion_id: poll.discussion_id).destroy_all

    parent_id = poll.discussion ? poll.discussion.created_event.id : nil
    res = Event.import [Event.new(kind: 'poll_created',
                                  user_id: poll.author_id,
                                  eventable_id: poll.id,
                                  eventable_type: "Poll",
                                  parent_id: parent_id,
                                  depth: 1,
                                  discussion_id: poll.discussion&.id,
                                  sequence_id: sequence_id_for(poll.discussion, poll.created_at),
                                  created_at: poll.created_at)]

    poll.stances.order(:created_at).each(&:created_event)
    # ensure there is a poll closed event?
    poll.outcomes.order(:created_at).each(&:created_event)

    poll.discussion.items.last.send(:reorder) if parent_id

    # TODO (or not TODO) ensure poll closed and expired events are sorted

    Events::PollCreated.find(res.ids.first.to_i)
  end

  def self.stance_created(stance)
    discussion = stance.poll.discussion
    Event.where(kind: "new_vote", discussion_id: discussion.id).destroy_all if discussion
    res = Event.import [Event.new(kind: 'stance_created',
                                  user_id: stance.participant_id,
                                  eventable_id: stance.id,
                                  eventable_type: "Stance",
                                  discussion_id: discussion&.id,
                                  depth: 2,
                                  parent_id: stance.poll.created_event.id,
                                  sequence_id: sequence_id_for(discussion, stance.created_at),
                                  created_at: stance.created_at)]
    Events::StanceCreated.find(res.ids.first.to_i)
  end

  def self.outcome_created(outcome)
    discussion = outcome.poll.discussion
    res = Event.import [Event.new(kind: 'outcome_created',
                                  user_id: outcome.author_id,
                                  eventable_id: outcome.id,
                                  eventable_type: "Outcome",
                                  discussion_id: discussion&.id,
                                  depth: 2,
                                  parent_id: outcome.poll.created_event.id,
                                  sequence_id: sequence_id_for(discussion, outcome.created_at),
                                  created_at: outcome.created_at)]
    Events::OutcomeCreated.find(res.ids.first.to_i)
  end


  def self.sequence_id_for(discussion, time)
    return nil if discussion.nil?
    id = (discussion.items.where("created_at < ?", time).order("created_at asc").last&.sequence_id || 0) + 1
    if Event.where(discussion_id: discussion.id, sequence_id: id).exists?
      Event.where(discussion_id: discussion.id).
            where("sequence_id >= ?", id).
            order(sequence_id: :desc).each do |event|
        event.update_attribute(:sequence_id, event.sequence_id + 1)
      end
    end
    id
  end
end
