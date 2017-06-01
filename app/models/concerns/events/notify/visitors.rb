module Events::Notify::Visitors
  include Events::Notify::Email

  # send event emails to visitors
  def email_visitors!
    email_visitors.can_receive_email.each { |recipient| email_visitor!(recipient) }
  end
  handle_asynchronously :email_visitors!

  private

  # which visitors should receive an email about this event?
  # (NB: This must return an ActiveRecord::Relation)
  def email_visitors
    Visitor.none
  end

end
