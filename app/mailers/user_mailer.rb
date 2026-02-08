class UserMailer < BaseMailer
  def redacted(email, locale)
    component = Views::UserMailer::Redacted.new

    send_email(to: email, locale: locale, component: component) {
      I18n.t("user_mailer.redacted.subject", site_name: AppConfig.theme[:site_name])
    }
  end

  def accounts_merged(user_id)
    user = User.find(user_id)
    token = user.login_tokens.create!

    component = Views::UserMailer::AccountsMerged.new(
      user: user, token: token, utm_hash: @utm_hash
    )

    send_email(to: user.email, locale: user.locale, component: component) {
      I18n.t("user_mailer.accounts_merged.subject", site_name: AppConfig.theme[:site_name])
    }
  end

  def merge_verification(source_user:, target_user:, hash:)
    component = Views::UserMailer::MergeVerification.new(
      source_user: source_user, target_user: target_user, hash_value: hash
    )

    send_email(to: target_user.email, locale: target_user.locale, component: component) {
      I18n.t("user_mailer.merge_verification.subject", site_name: AppConfig.theme[:site_name])
    }
  end

  def catch_up(user_id, time_since = nil, frequency = 'daily')
    user = User.find(user_id)
    return unless user.email_catch_up_day

    if frequency == 'daily'
      time_start = time_since || 24.hours.ago
    elsif frequency == 'other'
      time_start = time_since || 48.hours.ago
    else
      time_start = time_since || 1.week.ago
    end

    time_finish = Time.zone.now

    discussions = DiscussionQuery.visible_to(
      user: user,
      only_unread: true,
      or_public: false,
      or_subgroups: false).kept.last_activity_after(time_start)

    return if discussions.empty?

    groups = user.groups.order(full_name: :asc)
    cache = RecordCache.for_collection(discussions, user_id)
    discussions_by_group_id = discussions.group_by(&:group_id)
    subject_key = "email.catch_up.#{frequency}_subject"
    subject_params = { site_name: AppConfig.theme[:site_name] }

    component = Views::UserMailer::CatchUp.new(
      user: user,
      recipient: user,
      groups: groups,
      discussions_by_group_id: discussions_by_group_id,
      subject_key: subject_key,
      subject_params: subject_params,
      time_start: time_start,
      time_finish: time_finish,
      cache: cache,
      utm_hash: @utm_hash
    )

    send_email(to: user.email, locale: user.locale, component: component) {
      I18n.t(subject_key, **subject_params)
    }
  end

  def membership_request_approved(recipient_id, event_id)
    user = User.find_by(id: recipient_id)
    group = Event.find_by(id: event_id).eventable.group

    component = Views::UserMailer::MembershipRequestApproved.new(
      group: group, utm_hash: @utm_hash
    )

    send_email(to: user.email, locale: user.locale, component: component,
               reply_to: group.admin_email) {
      I18n.t("email.group_membership_approved.subject", group_name: group.full_name)
    }
  end

  def user_added_to_group(recipient_id, event_id)
    user    = User.find_by!(id: recipient_id)
    event   = Event.find_by!(id: event_id)
    group   = event.eventable.group
    inviter = event.eventable.inviter || group.admins.first

    component = Views::UserMailer::UserAddedToGroup.new(
      group: group, inviter: inviter, utm_hash: @utm_hash
    )

    send_email(to: user.email, locale: [user.locale, inviter.locale], component: component,
               from: from_user_via_loomio(inviter),
               reply_to: inviter.try(:name_and_email)) {
      I18n.t("email.user_added_to_group.subject",
        which_group: group.full_name,
        who: inviter.name,
        site_name: AppConfig.theme[:site_name])
    }
  end

  def group_export_ready(recipient_id, group_name, document_id)
    user     = User.find(recipient_id)
    document = Document.find(document_id)

    component = Views::UserMailer::GroupExportReady.new(
      document: document
    )

    send_email(to: user.email, locale: user.locale, component: component) {
      I18n.t("user_mailer.group_export_ready.subject", group_name: group_name)
    }
  end

  def login(user_id, token_id)
    user = User.find_by!(id: user_id)
    token = LoginToken.find_by!(id: token_id)

    component = Views::UserMailer::Login.new(
      user: user, token: token
    )

    send_email(to: user.email, locale: user.locale, component: component) {
      I18n.t("email.login.subject", site_name: AppConfig.theme[:site_name])
    }
  end

  def contact_request(contact_request:)
    return if spam?(contact_request.recipient.email)

    I18n.with_locale(first_supported_locale([contact_request.recipient.locale, contact_request.sender.locale])) do
      mail(
        to: contact_request.recipient.email,
        from: from_user_via_loomio(contact_request.sender),
        reply_to: contact_request.sender.name_and_email,
        subject: I18n.t("email.contact_request.subject",
          name: contact_request.sender.name,
          site_name: AppConfig.theme[:site_name])
      )
    end
  end
end
