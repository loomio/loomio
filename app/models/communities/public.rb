class Communities::Public < Communities::Base
  set_community_type :public

  def includes?(member)
    true
  end

  def members
    []
  end

  def notify!(event)
    # NOOP
  end
end
