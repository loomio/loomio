class Identities::Webhook < Identities::Base
  include Identities::WithClient
  set_identity_type :webhook
  set_custom_fields :event_kinds

  def valid_event_kinds
    event_kinds.to_a + ['group_identity_created']
  end
end
