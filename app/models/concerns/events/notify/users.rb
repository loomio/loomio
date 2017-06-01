module Events::Notify::Users
  include Events::Notify::Email

  # send event emails
  def email_users!
    email_recipients.without(user).each   { |recipient| email_user!(recipient) }
  end
  handle_asynchronously :email_users!

  # which users should receive an email about this event?
  # (NB: This must return an ActiveRecord::Relation)
  def email_recipients
    User.none
  end
end
