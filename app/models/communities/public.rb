class Communities::Public < Communities::Base

  def includes?(participant)
    true
  end

  def participants
    []
  end
end
