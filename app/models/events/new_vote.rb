class Events::NewVote < Event
  after_create :notify_users!

  def self.publish!(vote)
    create!(:kind => "new_vote", :eventable => vote,
                      :discussion_id => vote.motion.discussion.id)
  end

  def vote
    eventable
  end

  private

  def notify_users!
    voter = vote.user
    if voter != vote.motion_author
      notify!(vote.motion_author)
    end

    if voter != vote.discussion_author
      if vote.motion_author != vote.discussion_author
        notify!(vote.discussion_author)
      end
    end
  end

  handle_asynchronously :notify_users!
end
