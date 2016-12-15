class Communities::Public < Communities::Base
  set_community_type :public

  def includes?(participant)
    true
  end

  def participants
    []
  end
end
