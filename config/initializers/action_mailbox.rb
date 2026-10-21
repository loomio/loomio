ActiveSupport.on_load(:action_mailbox_inbound_email) do
  include InboundEmailRetention
end
