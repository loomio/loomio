class Identities::Microsoft < Identities::Base
  include Identities::WithClient
  set_identity_type :microsoft
  set_custom_fields :event_kinds

  def notify!(event)
    super(event) if event_kinds.to_a.include?(event.kind)
  end
end
