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

end