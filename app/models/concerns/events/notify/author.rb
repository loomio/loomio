module Events::Notify::Author
  def trigger!
    super
    email_author!
  end

  def email_author!
    eventable.send(:mailer).send(:"#{kind}_author", author, self).deliver_now if notify_author?
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
