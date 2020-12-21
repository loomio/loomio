class UserInviter
  def self.count(emails: , user_ids:, audience:, model:, usernames: , actor:)
    emails = Array(emails).map(&:presence).compact.uniq
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    usernames =  Array(usernames).map(&:presence).compact.uniq

    audience_ids = AnnouncementService.audience_users(model, audience).pluck(:id).without(actor.id)
    email_count = emails.count - User.where(email: emails).count
    user_count = User.where('email in (:emails) or id in (:user_ids) or username IN (:usernames)',
                            emails: emails,
                            usernames: usernames,
                            user_ids: user_ids.concat(audience_ids)).count
    email_count + user_count
  end

  def self.authorize!(emails: , user_ids:, audience:, model:, actor:)
    # check inviter can notify group if that's happening
    # check inviter can invite guests (from the org, or external) if that's happening
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    emails = Array(emails).map(&:presence).compact.uniq

    # members belong to group
    member_ids = model.members.where(id: user_ids).pluck(:id)

    # guests are outside of the group, but allowed to be referenced by user query
    guest_ids = UserQuery.invitable_user_ids(model: model, actor: actor, user_ids: user_ids - member_ids)

    actor.ability.authorize!(:announce, model)    if audience == 'group'
    actor.ability.authorize!(:add_members, model) if member_ids.any?
    actor.ability.authorize!(:add_guests, model)  if emails.any? or guest_ids.any?
  end

  def self.where_or_create!(emails:, user_ids:, audience: nil, model:, actor:)
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    emails = Array(emails).uniq.compact

    audience_ids = if audience
      AnnouncementService.audience_users(model, audience).pluck(:id).without(actor.id)
    else
      []
    end

    # guests are any user outside of the group
    # either by email address or by user_id, but user_ids are limited to your org
    member_ids = model.members.where(id: user_ids).pluck(:id)

    # guests are outside of the group, but allowed to be referenced by user query
    guest_ids = UserQuery.invitable_user_ids(model: model, actor: actor, user_ids: user_ids - member_ids)

    ids = member_ids.concat(guest_ids).concat(audience_ids).uniq

    ThrottleService.limit!(key: 'UserInviterInvitations',
                           id: actor.id,
                           max: actor.invitations_rate_limit,
                           inc: emails.length + ids.length,
                           per: :day)

    User.import(safe_emails(emails).map do |email|
      User.new(email: email, time_zone: actor.time_zone, detected_locale: actor.locale)
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
