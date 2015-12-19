
EventBus.listen('comment_create') { |comment| Events::CommentRepliedTo.publish!(comment) if comment.is_reply? }
EventBus.listen('comment_create') { |comment| comment.notified_group_members.each { |user| Events::UserMentioned.publish!(comment, user) } }

EventBus.listen('comment_update') do |comment, new_mentions|
  User.where(username: new_mentions).each { |user| Events::UserMentioned.publish!(comment, user) } if new_mentions.present?
end

EventBus.listen('comment_replied_to_event', 'user_mentioned_event') { |user, event| event.notify!(user) unless event.comment.author == user }
