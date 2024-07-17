module Events::Notify::Audiences
  def trigger!
    super
    self.notify_audiences!
  end

  # send event notifications
  def notify_audiences!
    return unless eventable.newly_mentioned_audiences.any?

    Events::CommentAnnounced.publish! eventable, user, eventable.newly_mentioned_audiences
  end
end
