class Events::NewDiscussion < Event
  def self.publish!(discussion)
    event = create!(:kind => "new_discussion", :eventable => discussion,
                      :discussion_id => discussion.id)

    # enfollow the author of the discussion
    DiscussionReader.for(discussion: discussion, user: user).follow!

    event.delay.email_followers!
  end

  def discussion
    eventable
  end

  private

  def email_followers!
    # email non author followers of the discussion
    followers = discussion.followers - [discussion.author]

    followers.each do |follower|
      if user.email_preferences.followed_threads?
        ThreadMailer.delay.new_discussion(discussion, user)
      end
    end
  end
end
