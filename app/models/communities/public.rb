class Communities::Public < Communities::Base
  set_community_type :public
  include Communities::EmailVisitors

  def includes?(member)
    true
  end

  def members
    visitors.where(revoked: false)
  end
end
