class Pending::StanceSerializer < Pending::MembershipSerializer
  def identity_type
    :stance
  end

  def group_id
    nil
  end
end
