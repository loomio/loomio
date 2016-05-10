class ResendIgnoredInvitationsJob < ActiveJob::Base
  def perform
    InvitationService.resend_ignored(send_count: 1, since: 1.day.ago)
    # We're not going to send a day 3 reminder right now. But I'll keep the code here so you get the idea.
    # InvitationService.resend_ignored(send_count: 2, since: 3.days.ago)
  end
end
