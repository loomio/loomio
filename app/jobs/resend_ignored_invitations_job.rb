class ResendIgnoredInvitationsJob < ActiveJob::Base
  def perform
    InvitationService.resend_ignored(send_count: 1, since: 1.day.ago)
  end
end
