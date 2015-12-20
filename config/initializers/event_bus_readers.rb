EventBus.listen('new_comment_event',
                'new_motion_event',
                'new_vote_event') { |event| DiscussionReader.for_model(event.eventable).author_thread_item!(event.created_at) }

EventBus.listen('discussion_create',
                'discussion_update') { |discussion, actor| DiscussionReader.for(discussion: discussion, user: actor).set_volume_as_required! }

EventBus.listen('comment_like')      { |comment_vote| DiscussionReader.for_model(comment_vote).set_volume_as_required! }

EventBus.listen('discussion_create') { |discussion| DiscussionReader.for(discussion: discussion, user: discussion.author).participate! }
