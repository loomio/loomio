class LoggedOutUser

  def id
    nil
  end

  def is_logged_in?
    false
  end

  def is_logged_out?
    !is_logged_in?
  end

  def uses_markdown?
    false
  end

  def belongs_to_manual_subscription_group?
    false
  end
end