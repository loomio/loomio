class Current < ActiveSupport::CurrentAttributes
  attribute :session, :request_ip, :permanently_deleting_group

  delegate :user, to: :session, allow_nil: true
end
