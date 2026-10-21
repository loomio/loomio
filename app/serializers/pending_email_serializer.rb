class PendingEmailSerializer < ApplicationSerializer
  attributes :id, :group_id, :released, :subject, :sender_email, :sender_name
end
