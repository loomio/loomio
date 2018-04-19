Queries::AnnouncementRecipients = Struct.new(:query, :user, :group) do
  def results
    email_result || user_results
  end

  private

  def email_result
    emails = query.scan(AppConfig::EMAIL_REGEX)
    case emails.length
    when 0
    when 1
      if !group.members.pluck(:email).include?(query)
        [User.new(email: emails.first, avatar_kind: 'mdi-email-outline')]
      end
    else
      [AnnouncementRecipientEmails.new(emails, user.locale)]
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
