class CalendarUpdateWorker < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 6

  def perform(poll_id)
    poll = Poll.find_by(id: poll_id)
    return unless poll&.event?

    poll.calendar_invitations.includes(:user).find_each do |invitation|
      next if invitation.delivered_sequence == poll.calendar_sequence
      next unless invitation.available?

      EventMailer.invitation(invitation.id).deliver_now
    end
  end
end
