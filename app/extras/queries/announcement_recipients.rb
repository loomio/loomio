Queries::AnnouncementRecipients = Struct.new(:query, :user) do
  def results
    if query.scan(AppConfig::EMAIL_REGEX).presence
      Array(User.new(email: query))
    else
      User.distinct.active.joins(:memberships).where.not(id: user).where(
        "memberships.archived_at": nil,
        "memberships.group_id": user.group_ids
      ).search_for(query)
    end
  end
end
