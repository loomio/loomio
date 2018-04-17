Queries::AnnouncementRecipients = Struct.new(:query, :user, :group) do
  def results
    email_result || user_results
  end

  private

  def email_result
    if query.scan(AppConfig::EMAIL_REGEX).presence && !group.members.pluck(:email).include?(query)
      Array(User.new(email: query).tap(&:set_avatar_initials))
    end
  end

  def user_results
    User.distinct.active
        .joins(:memberships)
        .where.not(id: [user.id, group.member_ids].flatten)
        .where("memberships.group_id": user.group_ids)
        .where("memberships.archived_at": nil)
        .search_for(query)
  end
end
