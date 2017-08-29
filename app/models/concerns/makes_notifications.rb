module MakesNotifications
  def notified=(hash)
    @notified = hash
  end

  def notified
    Array(@notified)
  end

  def notified_users
    @notified_users ||= User.distinct.where(id: notified_user_ids)
  end

  def notified_user_ids
    notified.map { |notified| Array(notified['notified_ids']) }.flatten
  end

  def notified_emails
    notified.select { |notified| notified['type'] == 'Invitation' }
            .map    { |notified| notified['id'] }
  end
end
