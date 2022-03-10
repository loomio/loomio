module Events::Notify::Author
  def trigger!
    super
    email_author!
  end

  def email_author!
    EventMailer.event(author, self).deliver_later if notify_author?
  end

  private
  def author
    eventable.author
  end

  # override if we want to send to the author conditionally
  def notify_author?
    true
  end
end
