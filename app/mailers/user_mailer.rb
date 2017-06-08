class UserMailer < BaseMailer
  helper :email
  helper :application
  layout 'invite_people_mailer', only: [:membership_request_approved, :user_added_to_group, :login, :start_decision]

  def missed_yesterday(user, time_since = nil)
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

    unless @discussions.empty? or @user.groups.empty?
      @discussions_by_group = @discussions.group_by(&:group)
      send_single_mail to: @user.email,
                       subject_key: "email.missed_yesterday.subject",
                       locale: locale_for(@user)
    end
  end

  def membership_request_approved(recipient, event)
    @user = recipient
    @group = event.eventable.group

    send_single_mail to: @user.email,
                     reply_to: @group.admin_email,
                     subject_key: "email.group_membership_approved.subject",
                     subject_params: {group_name: @group.full_name},
                     locale: locale_for(@user)
  end

  def user_added_to_group(recipient, event, message = nil)
    @user    = recipient
    @group   = event.eventable.group
    @inviter = event.eventable.inviter || @group.admins.first
    @message = message

    send_single_mail to: @user.email,
                     from: from_user_via_loomio(@inviter),
                     reply_to: @inviter.try(:name_and_email),
                     subject_key: "email.user_added_to_group.subject",
                     subject_params: { which_group: @group.full_name, who: @inviter.name },
                     locale: locale_for(@user, @inviter)
  end

  def analytics(user:, group:)
    @user, @group = user, group
    @stats = Queries::GroupAnalytics.new(group: group).stats
    send_single_mail to: @user.email,
                     subject_key: "email.analytics.subject",
                     subject_params: { which_group: @group.name },
                     locale: locale_for(@user)
  end

  def login(user:, token:)
    @user = user
    @token = token
    send_single_mail to: @user.email,
                     subject_key: "email.login.subject",
                     locale: locale_for(@user)
  end

  def start_decision(received_email:)
    @email = received_email
    send_single_mail to: @email.sender_email,
                     subject_key: "email.start_decision.subject",
                     locale: locale_for(@email)
  end
end
