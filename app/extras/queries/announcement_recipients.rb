Queries::AnnouncementRecipients = Struct.new(:query, :user, :model) do
  def results
    email_result || user_results
  end

  private

  def email_result
    emails = query.scan(AppConfig::EMAIL_REGEX)
    case emails.length
    when 0
    when 1
      if !model.group.members.pluck(:email).include?(query)
        [User.new(email: emails.first, avatar_kind: 'mdi-email-outline')]
      end
    else
      [AnnouncementRecipientEmails.new(emails, user.locale)]
    end
  end

  def user_results
    User.mention_search(user, model, query)
  end
end
