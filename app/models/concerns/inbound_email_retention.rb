# Keep the source available while a coordinator can still approve it. Once the
# queue record is removed, normal Action Mailbox cleanup can remove the source.
module InboundEmailRetention
  extend ActiveSupport::Concern

  included do
    has_one :pending_email, foreign_key: :inbound_email_id
  end

  def incinerate
    if pending_email
      # A group can remove the queue row through a cascading foreign key, which
      # bypasses its callbacks. Keep a future cleanup check in that case too.
      incinerate_later if ActionMailbox.incinerate
    else
      super
    end
  end
end
