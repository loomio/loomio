EventBus.instance.listen 'new_comment', { |comment| Events::CommentRepliedTo.publish! comment if comment.is_reply? }
