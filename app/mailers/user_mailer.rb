class UserMailer < BaseMailer
  layout 'invite_people_mailer', only: [:membership_request_approved, :contact_request, :user_added_to_group, :login, :start_decision, :accounts_merged, :user_reactivated, :group_export_ready]

  def accounts_merged(user)
    @user = user
    @token = user.login_tokens.create!
    send_single_mail to: @user.email,
                     subject_key: "user_mailer.accounts_merged.subject",
                     subject_params: { site_name: AppConfig.theme[:site_name] },
                     locale: @user.locale
  end

  def catch_up(user, time_since = nil, frequency = 'daily')
    return unless user.email_catch_up
    @recipient = @user = user
    @time_start = time_since || 24.hours.ago
    @time_finish = Time.zone.now
    @time_frame = @time_start...@time_finish

    @discussions = Queries::VisibleDiscussions.new(user: user)
                    .not_muted
                    .unread
                    .last_activity_after(@time_start)
    @groups = @user.groups.order(full_name: :asc)

    @reader_cache = Caches::DiscussionReader.new(user: @user, parents: @discussions)

    @subject_key = "email.catch_up.#{frequency}_subject"
    @subject_params = { site_name: AppConfig.theme[:site_name] }

    unless @discussions.empty? or @user.groups.empty?
      @discussions_by_group = @discussions.group_by(&:group)
      send_single_mail to: @user.email,
                       subject_key: @subject_key,
                       subject_params: @subject_params,
                       locale: @user.locale
    end
  end

  def membership_request_approved(recipient, event)
    @user = recipient
    @group = event.eventable.group

    send_single_mail to: @user.email,
                     reply_to: @group.admin_email,
                     subject_key: "email.group_membership_approved.subject",
                     subject_params: {group_name: @group.full_name},
                     locale: @user.locale
  end

  def user_added_to_group(recipient, event)
    @user    = recipient
    @group   = event.eventable.group
    @inviter = event.eventable.inviter || @group.admins.first

    send_single_mail to: @user.email,
                     from: from_user_via_loomio(@inviter),
                     reply_to: @inviter.try(:name_and_email),
                     subject_key: "email.user_added_to_group.subject",
                     subject_params: { which_group: @group.full_name, who: @inviter.name, site_name: AppConfig.theme[:site_name] },
                     locale: [@user.locale, @inviter.locale]
  end

  def group_export_ready(recipient, group_name, document)
    @user     = recipient
    @document = document
    send_single_mail to: @user.email,
                     subject_key: "user_mailer.group_export_ready.subject",
                     subject_params: {group_name: group_name},
                     locale: @user.locale
  end

  def login(user:, token:)
    @user = user
    @token = token
    send_single_mail to: @user.email,
                     subject_key: "email.login.subject",
                     subject_params: {site_name: AppConfig.theme[:site_name]},
                     locale: @user.locale
  end

  def user_reactivated(recipient, event)
    @user = recipient
    @token = recipient.login_tokens.create(is_reactivation: true)
    send_single_mail to: @user.email,
                     subject_key: "email.reactivate.subject",
                     subject_params: {site_name: AppConfig.theme[:site_name]},
                     locale: @user.locale
  end

  def start_decision(received_email:)
    @email = received_email
    send_single_mail to: @email.sender_email,
                     subject_key: "email.start_decision.subject",
                     locale: @email.locale
  end

  def contact_request(contact_request:)
    @contact_request = contact_request

    send_single_mail to: @contact_request.recipient.email,
                     from: from_user_via_loomio(@contact_request.sender),
                     reply_to: @contact_request.sender.name_and_email,
                     subject_key: "email.contact_request.subject",
                     subject_params: { name: @contact_request.sender.name,
                                       site_name: AppConfig.theme[:site_name]},
                     locale: [@contact_request.recipient.locale, @contact_request.sender.locale]
  end

end
