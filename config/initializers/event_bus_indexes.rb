EventBus.listen('discussion_create', 'discussion_update') { |discussion| SearchVector.index! discussion.id }
EventBus.listen('motion_create', 'motion_update')         { |motion|     SearchVector.index! motion.discussion_id }
EventBus.listen('comment_create', 'comment_update')       { |comment|    SearchVector.index! comment.discussion_id }
