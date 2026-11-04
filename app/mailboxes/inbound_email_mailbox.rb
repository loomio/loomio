class InboundEmailMailbox < ApplicationMailbox
  def process
    bounced! if InboundEmailService.process(inbound_email) == :bounced
  end
end
