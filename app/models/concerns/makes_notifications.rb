module MakesNotifications
  def notified=(hash)
    @notified = Array(hash)
  end

  def notified
    Array(@notified).map(&:with_indifferent_access)
  end

  def notified_when_created
    events.find_by(kind: created_event_kind)&.custom_fields&.dig('notified')
  end

  def notified_users
    @notified_users ||= User.distinct.where(id: notified_user_ids).without(new_mentioned_group_members)
  end

  def notified_user_ids
    notified.map { |notified| Array(notified['notified_ids']) }.flatten
  end

  def notified_emails
    notified.select { |notified| notified['type'] == 'Invitation' }
            .map    { |notified| notified['id'] }
  end

  def created_event_kind
    :"#{self.class.to_s.downcase}_created"
  end
end
