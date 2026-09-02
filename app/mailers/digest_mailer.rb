class DigestMailer < ApplicationMailer
  # Build one catch-up window from unseen notifications and unread topics, and skip delivery when the schedule is disabled or the window is empty.
  def digest(user_id, time_since = nil, frequency = 'daily')
    user = User.find(user_id)
    return unless user.email_catch_up_day

    time_start = time_since || period_for(frequency).ago
    time_finish = Time.zone.now
    digest = DigestQuery.new(user: user, time_start: time_start, time_finish: time_finish)
    return if digest.empty?

    subject = I18n.with_locale(first_supported_locale(user.locale)) do
      digest.subject(frequency: frequency, site_name: AppConfig.theme[:site_name])
    end
    component = Views::DigestMailer::Digest.new(
      user: user,
      recipient: user,
      notifications: digest.notifications,
      topics_by_group_id: digest.topics.group_by(&:group_id),
      time_start: time_start,
      time_finish: time_finish,
      utm_hash: @utm_hash
    )

    send_email(to: user.email, locale: user.locale, component: component) { subject }
  end

  private

  def period_for(frequency)
    case frequency
    when 'daily' then 24.hours
    when 'other' then 48.hours
    else 1.week
    end
  end
end
