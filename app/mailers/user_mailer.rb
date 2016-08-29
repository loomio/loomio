class UserMailer < BaseMailer
  helper :email
  helper :application
  layout 'invite_people_mailer', only: [:group_membership_approved, :added_to_group]

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

    @reader_cache = DiscussionReaderCache.new(user: @user, discussions: @discussions)

    unless @discussions.empty? or @user.groups.empty?
      @discussions_by_group = @discussions.group_by(&:group)
      send_single_mail to: @user.email,
                       subject_key: "email.missed_yesterday.subject",
                       locale: locale_fallback(user.locale)
    end
  end

  def group_membership_approved(user, group)
    @user = user
    @group = group

    send_single_mail to: @user.email,
                     reply_to: @group.admin_email,
                     subject_key: "email.group_membership_approved.subject",
                     subject_params: {group_name: @group.full_name},
                     locale: locale_fallback(@user.locale)
  end

  def added_to_group(user: nil, inviter: nil, group: nil, message: nil)
    @user = user
    @inviter = inviter || group.admins.first
    @group = group
    @message = message

    send_single_mail to: @user.email,
                     from: from_user_via_loomio(@inviter),
                     reply_to: inviter.try(:name_and_email),
                     subject_key: "email.user_added_to_group.subject",
                     subject_params: { which_group: group.full_name, who: @inviter.name },
                     locale: locale_fallback(user.try(:locale), inviter.try(:locale))
  end

  def analytics(user:, group:, stats: nil)
    @user, @group = user, group
    @stats = stats || Queries::GroupAnalytics.new(group: group).stats
    send_single_mail to: @user.email,
                     subject_key: "email.analytics.subject",
                     subject_params: { which_group: @group.name },
                     locale: locale_fallback(user.locale)
  end
end
