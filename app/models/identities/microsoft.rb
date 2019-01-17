class Identities::Microsoft < Identities::Base
  include Identities::WithClient
  set_identity_type :microsoft
  set_custom_fields :event_kinds

  def valid_event_kinds
    event_kinds.to_a + ['group_identity_created']
  end
end
