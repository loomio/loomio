class UserInviter
  def self.count(emails: , user_ids:, chatbot_ids:, audience:, model:, actor:, exclude_members: false, include_actor: false)
    emails = Array(emails).map(&:presence).compact.uniq
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    chatbot_ids = Array(chatbot_ids).uniq.compact.map(&:to_i)

    audience_ids = AnnouncementService.audience_users(
      model, audience, actor, exclude_members, include_actor).pluck(:id)
    user_ids = UserQuery.invitable_user_ids(model: model, actor: actor, user_ids: user_ids)
    email_count = emails.count - User.where(email: emails).count
    users = User.active.where(
      'email in (:emails) or id in (:user_ids)',
      emails: emails,
      user_ids: user_ids.concat(audience_ids)
    )
    users = users.where.not(id: model.voter_ids) if exclude_members && model.respond_to?(:voter_ids)
    email_count + users.count + chatbot_ids.length
  end

  def self.authorize_add_members!(parent_group:, group_ids:, emails:, user_ids:, actor: )
    subscription = Subscription.for(parent_group)

    raise Subscription::NotActive unless subscription.is_active?

    # authorize ability to add members to selected groups
    Group.where(id: group_ids).each do |g|
      actor.ability.authorize!(:add_members, g)
    end

    return if subscription.max_members.nil?

    new_count = new_members_count(parent_group: parent_group, user_ids: user_ids, emails: emails)
    existing_count = existing_members_count(parent_group)

    if (existing_count + new_count) > parent_group.subscription.max_members.to_i
      raise Subscription::MaxMembersExceeded
    end
  end

  def self.existing_members_count(parent_group)
    if parent_group.subscription.plan == 'trial'
      parent_group.all_memberships.count
    else
      parent_group.org_members_count
    end
  end

  # how many totally new members are being added right now?
  def self.new_members_count(parent_group:, user_ids:, emails:)
    new_emails_count =
      emails.uniq.count -
      Membership.active.where(
        group_id: parent_group.id_and_subgroup_ids,
        user_id: User.where(email: emails).pluck(:id),
      ).count

    new_user_ids_count =
      user_ids.uniq.count -
      Membership.active.where(
        group_id: parent_group.id_and_subgroup_ids,
        user_id: user_ids,
      ).count

    new_emails_count + new_user_ids_count
  end

  def self.authorize_preview!(model:, actor:, emails:, audience:)
    authorize_recipient_discovery!(model: model, actor: actor)
    auth_target = model.respond_to?(:topic) ? model.topic : model

    if %w[group discussion_group].include?(audience)
      action = model.is_a?(Group) ? :notify : :announce
      actor.ability.authorize!(action, model)
    end

    emails = Array(emails).map(&:presence).compact
    emails -= model.members.where(email: emails).pluck(:email) if model
    return if emails.empty? || auth_target.nil?

    actor.ability.authorize!(:add_guests, auth_target)
  end

  def self.authorize_recipient_discovery!(model:, actor:)
    if model
      auth_target = model.respond_to?(:topic) ? model.topic : model
      actor.ability.authorize!(:members_autocomplete, auth_target)
    else
      discussion = DiscussionService.build(params: {}, actor: actor)
      actor.ability.authorize!(:create, discussion)
    end
  end

  def self.authorize!(emails: , user_ids:, audience:, model:, actor:)
    # check inviter can notify group if that's happening
    # check inviter can invite guests (from the org, or external) if that's happening
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    emails = Array(emails).map(&:presence).compact.uniq

    # members belong to group
    member_ids = model.members.where(id: user_ids).pluck(:id)
    member_ids += model.members.where(email: emails).pluck(:id)

    emails -= User.where(email: emails, id: member_ids).pluck(:email)

    # guests are outside of the group, but allowed to be referenced by user query
    guest_ids = UserQuery.invitable_user_ids(model: model, actor: actor, user_ids: user_ids - member_ids)

    actor.ability.authorize!(:announce, model) if %w[group discussion_group].include?(audience)
    auth_target = model.respond_to?(:topic) ? model.topic : model
    actor.ability.authorize!(:add_members, auth_target) if member_ids.any?
    actor.ability.authorize!(:add_guests, auth_target)  if emails.any? or guest_ids.any?
  end

  def self.where_existing(user_ids:, audience:, model:, actor:)
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    audience_ids = AnnouncementService.audience_users(model, audience, actor).pluck(:id)
    model.members.where('users.id': user_ids + audience_ids)
  end

  def self.where_or_create!(emails:, user_ids:, audience: nil, model:, actor:, include_actor: false)
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    emails = Array(emails).uniq.compact

    audience_ids = if audience
      AnnouncementService.audience_users(model, audience, actor, false, include_actor).pluck(:id)
    else
      []
    end

    # guests are any user outside of the group, and not yet invited
    # either by email address or by user_id, but user_ids are limited to your org
    member_ids = model.members.where(id: user_ids).pluck(:id)

    # guests are outside of the group, but allowed to be referenced by user query
    guest_ids = UserQuery.invitable_user_ids(model: model, actor: actor, user_ids: user_ids - member_ids)

    ids = member_ids.concat(guest_ids).concat(audience_ids).uniq

    invitations_limit_max = actor.invitations_rate_limit
    if invitations_limit_max
      ThrottleService.limit!(key: 'UserInviterInvitations',
                             id: actor.id,
                             max: invitations_limit_max,
                             inc: emails.length + ids.length,
                             per: :day)
    end

    users_insert_all(emails: safe_emails(emails), actor: actor)

    User.active.where("id in (:ids) or email in (:emails)", ids: ids, emails: emails)
  end

  private

  def self.safe_emails(emails)
    emails.uniq.select do |email|
      email.present? &&
        email.length <= 200 &&
        EmailValidator::EMAIL_REGEXP.match?(email) &&
        NoSpam::SPAM_REGEX.match?(email) == false
    end
  end

  def self.users_insert_all(emails:, actor:)
    return if emails.empty?

    wday = Date.today.wday
    rows = emails.map do |email|
      user = User.new(
        email: email,
        time_zone: actor.time_zone,
        date_time_pref: actor.date_time_pref,
        detected_locale: actor.locale,
        email_catch_up_day: wday
      )
      user.username = username_for_insert(email)
      user.key = key_for_insert
      user.set_avatar_initials

      user.attributes.slice(
        'email',
        'username',
        'key',
        'avatar_initials',
        'unsubscribe_token',
        'email_api_key',
        'api_key',
        'secret_token',
        'time_zone',
        'date_time_pref',
        'detected_locale',
        'email_catch_up_day'
      )
    end

    User.insert_all(rows)
  end

  def self.username_for_insert(email)
    base = ActiveSupport::Inflector.transliterate(email.split('@').first)
                                           .downcase
                                           .gsub(/[^a-z0-9]+/, '')[0, 18]
    "#{base}#{SecureRandom.alphanumeric(12).downcase}"
  end

  def self.key_for_insert
    loop do
      key = SecureRandom.alphanumeric(ReadableUnguessableUrls::KEY_LENGTH)
      return key unless key.match?(/^\d+$/)
    end
  end
end
