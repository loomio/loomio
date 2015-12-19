
EventBus.listen('comment_create') { |comment| Events::CommentRepliedTo.publish!(comment) }
EventBus.listen('comment_create') { |comment| comment.notified_group_members.each { |user| Events::UserMentioned.publish!(comment, user) } }

EventBus.listen('membership_request_approved_event',
                'comment_replied_to_event',
                'user_mentioned_event',
                'motion_closed') { |user, event| event.notify!(user) }

EventBus.listen('comment_update') do |comment, new_mentions|
  User.where(username: new_mentions).each { |user| Events::UserMentioned.publish!(comment, user) } if new_mentions.present?
end

EventBus.listen('motion_closing_soon_event') do |event|
  UsersByVolumeQuery.normal_or_loud(event.discussion).find_each { |user| event.notify!(user) }
end

EventBus.listen('motion_outcome_created_event') do |event|
  UsersByVolumeQuery.normal_or_loud(event.discussion).without(event.motion.outcome_author).find_each { |user| event.notify!(user) }
end
