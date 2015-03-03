class Events::NewComment < Event
  def self.publish!(comment)
    event = create!(kind: 'new_comment',
                    eventable: comment,
                    discussion: comment.discussion,
                    created_at: comment.created_at)

    if comment.author.email_on_participation?
      DiscussionReader.for(user: comment.author,
                           discussion: comment.discussion).change_volume! :email
    end

    Events::CommentRepliedTo.publish! comment if comment.is_reply?

    comment.mentioned_group_members.
            without(comment.parent_author).each do |mentioned_user|
      Events::UserMentioned.publish!(comment, mentioned_user)
    end

    ThreadMailerQuery.users_to_email_new_comment(comment).each do |user|
      ThreadMailer.delay.new_comment(user, event)
    end

    event

  end

  def comment
    eventable
  end

  def message_channel
    "/discussion-#{comment.discussion.key}" #/#{kind}"
  end
end
