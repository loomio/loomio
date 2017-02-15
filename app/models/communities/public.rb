class Communities::Public < Communities::Base
  set_community_type :public

  def self.instance_relation
    where(id: instance.id)
  end

  def self.instance
    find_or_create_by(community_type: :public)
  end

  def save
    if self.class.where(community_type: :public).empty?
      super
    else
      false
    end
  end

  def includes?(participant)
    true
  end

  def participants
    []
  end

  def notify!(event)
    # noop
  end
end
