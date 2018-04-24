module Events::Notify::Author
  def trigger!
    super
    email_author!
  end

  def email_author!
    eventable.send(:mailer).send(:"#{kind}_author", author, self).deliver_now if notify_author?
  end

  # override to specify a custom subject for emails sent by this event
  def email_subject_key
    nil
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
