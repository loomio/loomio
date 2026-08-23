class InvitationReminderService
  def self.resend_pending(since: 25.hours.ago, till: 24.hours.ago)
    Membership.pending
              .where.not(inviter_id: nil)
              .where(created_at: since.beginning_of_hour..till.beginning_of_hour)
              .includes(:inviter)
              .find_each.map do |membership|
      NotificationService.create!(
        kind: "membership_resent",
        subject: membership,
        actor: membership.inviter
      )
    end
  end
end
