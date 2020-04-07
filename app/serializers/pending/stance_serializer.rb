class Pending::StanceSerializer < Pending::MembershipSerializer
  def identity_type
    :stance
  end
end
