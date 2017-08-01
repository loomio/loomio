module Events::Notify::Author
  def trigger!
    super
    email_author!
  end

  def email_author!
    mailer.send(:"#{kind}_author", eventable.author, self).deliver_now if notify_author?
  end

  private

  # override if we want to send to the author conditionally
  def notify_author?
    true
  end
end
