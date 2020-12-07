class UserInviter
  def self.where_or_create!(emails:, user_ids:, inviter:, model:, audience: nil)
    user_ids = Array(user_ids).uniq.compact
    emails = Array(emails).uniq.compact

    audience_ids = if audience
      AnnouncementService.audience_users(model, audience).pluck(:id).without(inviter.id)
    else
      []
    end

    # ensure you can only reference users who are guests of the model or in your org
    org_user_ids = Membership.where(group_id: model.group.parent_or_self.id_and_subgroup_ids,
                                    user_id: user_ids).pluck(:user_id)
    model_user_ids = model.members.where(id: user_ids).pluck(:id)

    ids = org_user_ids.concat(model_user_ids).concat(audience_ids).uniq

    ThrottleService.limit!(key: 'UserInviterInvitations',
                           id: inviter.id,
                           max: inviter.invitations_rate_limit,
                           inc: emails.length + ids.length,
                           per: :day)

    User.import(safe_emails(emails).map do |email|
      User.new(email: email, time_zone: inviter.time_zone, detected_locale: inviter.locale)
    end, on_duplicate_key_ignore: true)

    User.active.where("id in (:ids) or email in (:emails)", ids: ids, emails: emails)
  end

  private

  def self.safe_emails(emails)
    if ENV['SPAM_REGEX']
      emails.uniq.reject {|email| Regexp.new(ENV['SPAM_REGEX']).match(email) }
    else
      emails.uniq
    end
  end
end
