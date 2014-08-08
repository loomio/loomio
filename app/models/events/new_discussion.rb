class Events::NewDiscussion < Event
  def self.publish!(discussion)
    event = create!(:kind => "new_discussion", :eventable => discussion,
                      :discussion_id => discussion.id)

    # enfollow the author of the discussion
    DiscussionReader.for(discussion: discussion,
                         user: discussion.author).follow!

    event.delay.email_followers!
    event
  end

  def discussion
    eventable
  end

  private

  def email_followers!
    followers_without_author.each do |follower|
      if user.email_preferences.followed_threads?
        ThreadMailer.delay.new_discussion(discussion, user)
      end
    end
  end

  def followers_without_author
    discussion.followers - [discussion.author]
  end
end
