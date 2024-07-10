module Events::Notify::Audiences
  LIST = %w[group discussion]

  def trigger!
    super
    self.notify_audiences!
  end

  # send event notifications
  def notify_audiences!
    return unless eventable.newly_mentioned_audiences.any?

    Events::CommentAnnounced.publish! eventable, user, audience_users
  end

  private

  # remove newly_mentioned_audiences from those emailed
  def email_recipients
    super.where.not(id: eventable.newly_mentioned_audiences)
  end

  def audience_users
    users = []
    audiences = Hash.new('group').merge('discussion' => 'discussion_group')

    eventable.newly_mentioned_audiences.each do |audience|
      users += AnnouncementService.audience_users(eventable,
                                                    audiences[audience],
                                                    eventable.author,
                                                    false,
                                                    false)
    end

    users.uniq
  end
end
