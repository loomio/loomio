Queries::Notified::Search = Struct.new(:query, :user) do

  def results
    @results ||= (visible_users + visible_groups + visible_invitations).presence || nobody_found
  end

  private

  def visible_users
    User.distinct.active.joins(:memberships).where.not(id: user).where(
      "memberships.archived_at": nil,
      "memberships.group_id": user.group_ids
    ).search_for(query).map { |user| Notified::User.new(user) }
  end

  def visible_groups
    user.formal_groups
        .search_for(query)
        .map    { |group| Notified::Group.new(group, user) }
        .select { |notified| notified.notified_ids.length > 0 }
  end

  def visible_invitations
    Array(query.scan(AppConfig::EMAIL_REGEX)).map { |email| Notified::Invitation.new(email) }
  end

  def nobody_found
    Array(Notified::Null.new(query))
  end

end
