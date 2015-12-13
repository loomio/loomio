
EventBus.listen('comment_replied_to_event') { |user, event| user.notify! event }
EventBus.listen('user_mentioned_event')     { |user, event| user.notify! event }
