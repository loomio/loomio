namespace :migrate do
  task event_parents: :environment do
    total_comments = Comment.where("parent_id is not null").count

    # UPDATE events
    # SET parent_id = parent_events.id
    # FROM events parent_events INNER JOIN comments ON parent_events.eventable_id = comments.id AND parent_events.eventable_type = 'Comment'
    # WHERE comments.parent_id IS NOT NULL
    # AND parent_events.kind = 'new_comment'

    # Comment.order("id DESC").limit(10000).where("parent_id IS NOT NULL").each do |comment|
    #   puts "#{comment.id} of #{total_comments} comments"
    #   event = comment.events.find_by(kind: 'new_comment')
    #   parent_event = comment.parent.events.find_by(kind: 'new_comment')
    #   return unless event && parent_event
    #   event.update_attribute(:parent_id, parent_event.id)
    # end

    total_polls = Poll.count
    Poll.find_each do |poll|
      puts "#{poll.id} of #{total_polls} polls"
      next unless parent_event = poll.events.find_by(kind: "poll_created")
      Event.where(kind: "stance_created", eventable_id: poll.stance_ids)
           .update_all(parent_id: parent_event.id)
    end
  end
end
