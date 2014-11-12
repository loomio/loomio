class Events::NewComment < Event
  def self.publish!(comment)
    event = create!(kind: 'new_comment',
                    eventable: comment,
                    discussion: comment.discussion,
                    created_at: comment.created_at)

    DiscussionReader.for(user: comment.author,
                         discussion: comment.discussion).follow!

    comment.mentioned_group_members.each do |mentioned_user|
      Events::UserMentioned.publish!(comment, mentioned_user)
    end

    comment.non_mentioned_followers_without_author.
            email_followed_threads.each do |user|
      ThreadMailer.delay.new_comment(user, event)
    end

    event
  end

  def comment
    eventable
  end

  def message_channel
    "/discussion-#{comment.discussion_id}" #/#{kind}"
  end
end
