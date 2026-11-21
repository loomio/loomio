class Current < ActiveSupport::CurrentAttributes
  attribute :session, :request_ip

  delegate :user, to: :session, allow_nil: true
end
