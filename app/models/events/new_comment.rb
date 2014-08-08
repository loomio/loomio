class Events::NewComment < Event
  def self.publish!(comment)
    create!(:kind => "new_comment",
            :eventable => comment,
            :discussion_id => comment.discussion.id)

    # Enfollow the comment author
    DiscussionReader.for(user: comment.author,
                         discussion: comment.discussion).follow!

    event.delay.create_mention_events!
    event.delay.email_followers!
  end

  def comment
    eventable
  end

  private

  def create_mention_events!
    # create any mention events
    comment.mentioned_group_members.each do |mentioned_user|
      Events::UserMentioned.publish!(comment, mentioned_user)
    end
  end

  def email_followers!
    followers = comment.discussion.followers -
                comment.mentioned_group_members -
                [comment.author]

    followers.each do |follower|
      if follower.email.followed_threads?
        ThreadMailer.delay.new_comment(follower, comment)
      end
    end
  end

end

