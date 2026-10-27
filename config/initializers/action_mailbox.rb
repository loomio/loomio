ActiveSupport.on_load(:action_mailbox_inbound_email) do
  include InboundEmailRetention
end

Rails.application.config.to_prepare do
  # Active Job counts the initial attempt, so six attempts allow five retries.
  ActionMailbox::RoutingJob.retry_on StandardError, wait: :polynomially_longer, attempts: 6
end
