class Events::NewComment < Event
  def self.publish!(comment)
    event = create!(kind: 'new_comment',
                    eventable: comment,
                    discussion: comment.discussion,
                    created_at: comment.created_at)

    Events::CommentRepliedTo.publish! comment if comment.is_reply?

    comment.mentioned_group_members.
            without(comment.parent_author).find_each do |mentioned_user|
      Events::UserMentioned.publish!(comment, mentioned_user)
    end

    BaseMailer.send_bulk_mail(to: UsersToEmailQuery.new_comment(comment)) do |user|
      ThreadMailer.delay.new_comment(user, event)
    end

    event
  end

  def group_key
    discussion.group.key
  end

  def discussion_key
    discussion.key
  end

  def comment
    eventable
  end
end
