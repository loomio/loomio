class Communities::Public < Communities::Base
  include Communities::Notify::Visitors
  set_community_type :public

  def includes?(participant)
    true
  end
end
