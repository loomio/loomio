class Pending::StanceSerializer < Pending::MembershipSerializer
  def auth_form
    false
  end
  
  def identity_type
    :stance
  end

  def group_id
    nil
  end
end
