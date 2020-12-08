class UserInviter
  def self.authorize!(emails: , user_ids:, audience:, model:, actor:)
    # check inviter can notify group if that's happening
    # check inviter can invite guests (from the org, or external) if that's happening
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    emails = Array(emails).uniq.compact

    member_ids = model.members.where(id: user_ids).pluck(:id)
    guest_ids = Membership.where(group_id: model.group.parent_or_self.id_and_subgroup_ids,
                                 user_id: (user_ids - member_ids)).pluck(:user_id).uniq


    # disallow inviting anyone by user_id if they're not in the org
    raise CanCan::AccessDenied if ((user_ids - member_ids) - guest_ids).any?
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
    guest_ids = Membership.where(group_id: model.group.parent_or_self.id_and_subgroup_ids,
                                 user_id: (user_ids - member_ids)).pluck(:user_id).uniq

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
