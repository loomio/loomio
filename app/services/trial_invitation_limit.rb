require 'ipaddr'

class TrialInvitationLimit
  # Reserve recipients inside the notification transaction. An IP lock protects
  # the shared allowance across accounts; rollback releases every reservation.
  # Keep this short-lived abuse data separate from exported group content.
  def self.reserve!(actor:, user_ids:)
    recipients = user_ids.map(&:to_i).uniq - [ actor.id ]
    return if recipients.empty? || !AppConfig.app_features[:subscriptions] || actor.is_paying?

    ip = Current.request_ip.presence || actor.current_sign_in_ip
    return if ip.blank?
    ip = IPAddr.new(ip.to_s).native.to_s
    connection = TrialInvitationRecipient.connection
    connection.execute(TrialInvitationRecipient.sanitize_sql_array([
      "SELECT pg_advisory_xact_lock(hashtext('loomio_trial_invitation_ip'), hashtext(?))", ip
    ]))

    now = Time.current
    history = TrialInvitationRecipient.where(ip_address: ip).where('invited_at > ?', now - 24.hours)
    actor_ids = history.distinct.pluck(:actor_id) | [ actor.id ]
    limit = UserInviter.invitation_limit_for(user_ids: actor_ids)
    invited_ids = history.distinct.pluck(:recipient_id)
    new_ids = recipients - invited_ids
    if limit && new_ids.any? && (invited_ids | new_ids).length > limit
      raise ThrottleService::LimitReached
    end

    TrialInvitationRecipient.upsert_all(
      recipients.map { |id| { ip_address: ip, actor_id: actor.id, recipient_id: id, invited_at: now } },
      unique_by: 'index_trial_invitation_recipients_identity'
    )
  end
end
