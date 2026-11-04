# Queue forwarding and rejection notices only after inbound processing commits.
class InboundEmailDeliveryJob < ActionMailer::MailDeliveryJob
  self.enqueue_after_transaction_commit = true
end
