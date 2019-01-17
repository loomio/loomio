class Identities::Microsoft < Identities::Base
  include Identities::WithClient
  set_identity_type :microsoft
  # NB: this overrides the default event_kinds defined in identities/with_client.rb
  set_custom_fields :event_kinds
end
