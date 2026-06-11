class AdminConstraint
  def matches?(request)
    session_id = request.cookie_jar&.signed&.[](:session_id)
    return false unless session_id

    Session.find_by(id: session_id)&.user&.is_admin?
  rescue
    false
  end
end
