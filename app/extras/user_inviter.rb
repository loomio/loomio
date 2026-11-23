class UserInviter
  INVITATION_KINDS = %w[
    membership_created membership_resent new_discussion discussion_edited
    discussion_announced poll_announced poll_edited poll_reminder
    outcome_created outcome_updated outcome_announced
  ].freeze
  DEFAULT_INVITATION_LIMIT = 10

  # Call inside the invitation's transaction, so concurrent requests by this
  # actor cannot both claim the last slot. Paid groups and private sites keep
  # their existing limits; repeated contact with the same person is allowed.
  def self.check_invitation_limit!(actor:, user_ids:)
    recipients = user_ids.map(&:to_i).uniq - [ actor.id ]
    return if recipients.empty? || !AppConfig.app_features[:subscriptions] || actor.is_paying?

    connection = User.connection
    lock_sql = User.sanitize_sql_array([ "SELECT pg_advisory_xact_lock(hashtext('loomio_invitation_limit'), ?)", actor.id ])
    connection.execute(lock_sql)
    limit = invitation_limit(actor: actor)
    return if limit.nil?

    invited_ids = User.uncached { invited_user_ids(actor: actor) }
    new_ids = recipients - invited_ids
    if new_ids.any? && (invited_ids | new_ids).length > limit
      raise ThrottleService::LimitReached
    end
  end

  # Trial extensions also extend invitations. Subgroup members inherit their
  # parent's allowance; multiple trials use the highest limit, not their sum.
  # A nil member limit already means unlimited membership for that trial.
  def self.invitation_limit(actor:)
    invitation_limit_for(user_ids: [ actor.id ])
  end
  private_class_method :invitation_limit

  def self.invitation_limit_for(user_ids:)
    group_ids = Group.enabled.joins(:memberships)
      .where(memberships: { user_id: user_ids, revoked_at: nil })
      .pluck('groups.id', 'groups.parent_id').flatten.compact.uniq
    limits = Group.enabled.where(id: group_ids, parent_id: nil).joins(:subscription)
      .where(subscriptions: { plan: 'trial' }).pluck('subscriptions.max_members')
    return if limits.include?(nil)

    [ DEFAULT_INVITATION_LIMIT, *limits ].max
  end

  # UNION counts each person once across access grants, electorate records and
  # invitation notifications. Revoked rows count until they are actually deleted.
  def self.invited_user_ids(actor:)
    scopes = [
      Membership.where(inviter_id: actor.id).select(:user_id),
      TopicReader.where(inviter_id: actor.id, guest: true).select(:user_id),
      Stance.where(inviter_id: actor.id).select(:participant_id),
      AnonymousPollVoter.where(inviter_id: actor.id).select(:voter_id),
      Notification.where(actor_id: actor.id, kind: INVITATION_KINDS).select('unnest(recipient_user_ids)')
    ]
    User.connection.select_values(scopes.map(&:to_sql).join(' UNION ')).map(&:to_i) - [ actor.id ]
  end
  private_class_method :invited_user_ids

  def self.count(emails:, user_ids:, chatbot_ids:, audience:, model:, actor:, exclude_members: false, include_actor: false)
    emails = Array(emails).map(&:presence).compact.uniq
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    chatbot_ids = Array(chatbot_ids).uniq.compact.map(&:to_i)

    audience_user_ids = NotificationAudienceService.resolve(
      model: model,
      kind: audience,
      actor: actor,
      exclude_members: exclude_members,
      include_actor: include_actor
    ).pluck(:id)
    user_ids = UserQuery.invitable_user_ids(model: model, actor: actor, user_ids: user_ids)
    email_count = emails.count - User.where(email: emails).count
    users = User.active.where(
      'email in (:emails) or id in (:user_ids)',
      emails: emails,
      user_ids: user_ids.concat(audience_user_ids)
    )
    users = users.where.not(id: model.voter_ids) if exclude_members && model.respond_to?(:voter_ids)
    email_count + users.count + chatbot_ids.length
  end

  def self.authorize_add_members!(parent_group:, group_ids:, emails:, user_ids:, actor:)
    subscription = Subscription.for(parent_group)

    raise Subscription::NotActive unless subscription.is_active?

    # authorize ability to add members to selected groups
    Group.where(id: group_ids).each do |g|
      actor.ability.authorize!(:add_members, g)
    end

    emails = Array(emails).map(&:presence).compact.uniq
    authorize_email_invitations!(emails: emails, model: parent_group, actor: actor)

    check_members_limit!(parent_group: parent_group, emails: emails, user_ids: user_ids)
  end

  # Server provisioning checks the same subscription constraints after its
  # controller has authenticated the server key, without inventing a user actor.
  def self.check_members_limit!(parent_group:, emails:, user_ids:)
    subscription = Subscription.for(parent_group)
    raise Subscription::NotActive unless subscription.is_active?
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

    if %w[group topic].include?(audience)
      NotificationAudienceService.authorize_notify!(model: model, actor: actor)
    end

    emails = Array(emails).map(&:presence).compact.uniq
    authorize_email_invitations!(emails: emails, model: model, actor: actor)
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

  def self.authorize!(emails:, user_ids:, audience:, model:, actor:)
    # check inviter can notify group if that's happening
    # check inviter can invite guests (from the org, or external) if that's happening
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    emails = Array(emails).map(&:presence).compact.uniq
    authorize_email_invitations!(emails: emails, model: model, actor: actor)
    # Nobody can notify people from a locked thread, including thread admins
    # who can still edit it.
    topic = model.is_a?(Topic) ? model : (model.topic if model.respond_to?(:topic))
    if topic&.locked_at && (audience.present? || user_ids.any? || emails.any?)
      raise CanCan::AccessDenied
    end
    if audience.present?
      NotificationAudienceService.resolve(model: model, kind: audience, actor: actor)
    end

    # members belong to group
    member_ids = model.members.where(id: user_ids).pluck(:id)
    member_ids += model.members.where(email: emails).pluck(:id)

    emails -= User.where(email: emails, id: member_ids).pluck(:email)

    # guests are outside of the group, but allowed to be referenced by user query
    guest_ids = UserQuery.invitable_user_ids(model: model, actor: actor, user_ids: user_ids - member_ids)

    if %w[group topic].include?(audience)
      NotificationAudienceService.authorize_notify!(model: model, actor: actor)
    end
    auth_target = model.respond_to?(:topic) ? model.topic : model
    actor.ability.authorize!(:add_members, auth_target) if member_ids.any?
    actor.ability.authorize!(:add_guests, auth_target)  if emails.any? or guest_ids.any?
  end

  def self.where_existing(user_ids:, audience:, model:, actor:)
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    audience_user_ids = NotificationAudienceService.resolve(
      model: model,
      kind: audience,
      actor: actor
    ).pluck(:id)
    model.members.where('users.id': user_ids + audience_user_ids)
  end

  def self.where_or_create!(emails:, user_ids:, audience: nil, model:, actor:, include_actor: false)
    SpamRules.with_context do
      resolve_invitees!(emails: emails, user_ids: user_ids, audience: audience, model: model, actor: actor, include_actor: include_actor)
    end
  end

  def self.resolve_invitees!(emails:, user_ids:, audience:, model:, actor:, include_actor:)
    user_ids = Array(user_ids).uniq.compact.map(&:to_i)
    emails = Array(emails).map(&:presence).compact.uniq
    authorize_email_invitations!(emails: emails, model: model, actor: actor)
    emails = safe_emails(emails)

    audience_user_ids = if audience
      NotificationAudienceService.resolve(
        model: model,
        kind: audience,
        actor: actor,
        include_actor: include_actor
      ).pluck(:id)
    else
      []
    end

    # guests are any user outside of the group, and not yet invited
    # either by email address or by user_id, but user_ids are limited to your org
    member_ids = model.members.where(id: user_ids).pluck(:id)

    # guests are outside of the group, but allowed to be referenced by user query
    guest_ids = UserQuery.invitable_user_ids(model: model, actor: actor, user_ids: user_ids - member_ids)

    ids = member_ids.concat(guest_ids).concat(audience_user_ids).uniq

    invitations_limit_max = actor.invitations_rate_limit
    if invitations_limit_max
      ThrottleService.limit!(key: 'UserInviterInvitations',
                             id: actor.id,
                             max: invitations_limit_max,
                             inc: emails.length + ids.length,
                             per: :day)
    end

    User.transaction do
      users_insert_all(emails: emails, actor: actor)
      users = User.active.where("id in (:ids) or email in (:emails)", ids: ids, emails: emails).load
      blocked_ids = users.select { |user| SpamRules.blocked?(user.email, target: :email, action: 'invitation') }.map(&:id)
      users = users.where.not(id: blocked_ids).load if blocked_ids.any?
      check_invitation_limit!(actor: actor, user_ids: users.map(&:id))
      users
    end
  end
  private_class_method :resolve_invitees!

  private

  def self.authorize_email_invitations!(emails:, model:, actor:)
    return if emails.empty?
    return if Subscription.email_invitations_allowed?(model: model, actor: actor)

    raise CanCan::AccessDenied
  end
  private_class_method :authorize_email_invitations!

  def self.safe_emails(emails)
    emails.uniq.select do |email|
      email.present? &&
        email.length <= 200 &&
        EmailValidator::EMAIL_REGEXP.match?(email) &&
        !SpamRules.blocked?(email, target: :email, action: 'invitation')
    end
  end

  def self.users_insert_all(emails:, actor:)
    return if emails.empty?

    rows = emails.map do |email|
      user = User.new(
        email: email,
        time_zone: actor.time_zone,
        date_time_pref: actor.date_time_pref,
        detected_locale: actor.locale
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
