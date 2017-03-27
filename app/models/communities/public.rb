class Communities::Public < Communities::Base
  include Communities::NotifyViaEmail
  set_community_type :public

  def includes?(participant)
    true
  end
end
