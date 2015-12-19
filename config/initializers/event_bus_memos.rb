EventBus.listen('comment_destroy') { |comment| Memos::CommentDestroyed.publish!(comment) }
EventBus.listen('comment_update')  { |comment| Memos::CommentUpdated.publish!(comment) }
EventBus.listen('comment_unlike')  { |comment_vote| Memos::CommentUnliked.publish!(comment: comment_vote.comment, user: comment_vote.user) }
