class Simple::GroupSerializer < GroupSerializer
  def include_parent?
    false
  end

  def include_current_user_membership?
    false
  end

  def include_subscription?
    false
  end
end
