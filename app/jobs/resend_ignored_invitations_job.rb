class ResendIgnoredInvitationsJob < ActiveJob::Base
  def perform
    InvitationService.resend_ignored(send_count: 1, since: 1.day.ago)
    InvitationService.resend_ignored(send_count: 2, since: 3.days.ago)
  end
end
