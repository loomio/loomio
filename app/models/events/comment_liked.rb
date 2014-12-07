class Events::CommentLiked < Event
  after_create :notify_users!

  def self.publish!(comment_vote)
    create!(kind: "comment_liked",
            eventable: comment_vote)
  end

  def comment_vote
    eventable
  end

  def message_channel
    "/discussion-#{comment_vote.comment.discussion.key}" #/#{kind}"
  end

  private

  def notify_users!
    unless comment_vote.user == comment_vote.comment_user
      notify!(comment_vote.comment_user)
    end
  end
end
