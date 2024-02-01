class ReceivedEmailSerializer < ApplicationSerializer
  attributes :id, :group_id, :released, :subject, :sender_email, :sender_name, :dkim_valid, :spf_valid
end
