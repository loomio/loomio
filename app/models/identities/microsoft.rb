class Identities::Microsoft < Identities::Base
  include Identities::WithClient
  set_identity_type :microsoft
end
