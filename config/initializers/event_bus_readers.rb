EventBus.listen('comment_create',
                'motion_create',
                'vote_create')       { |model| DiscussionReader.for_model(model).author_thread_item!(model.created_at) }

EventBus.listen('discussion_create',
                'discussion_update') { |discussion, actor| DiscussionReader.for(discussion: discussion, user: actor).set_volume_as_required! }

EventBus.listen('comment_like')      { |comment_vote| DiscussionReader.for_model(comment_vote).set_volume_as_required! }

EventBus.listen('discussion_create') { |discussion| DiscussionReader.for(discussion: discussion, user: discussion.author).participate! }
