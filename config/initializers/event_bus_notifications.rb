
EventBus.listen('comment_create') { |comment| comment.notified_group_members.each { |user| Events::UserMentioned.publish!(comment, user) } }
EventBus.listen('comment_create') { |comment| Events::CommentRepliedTo.publish!(comment) if comment.is_reply? }

EventBus.listen('comment_replied_to_event') { |user, event| event.notify! user }
EventBus.listen('user_mentioned_event')     { |user, event| event.notify! user }
