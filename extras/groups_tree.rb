class GroupsTree
  def initialize(user)
    @user = user
  end

  def self.for_user(user)
    new(user)
  end

  def to_a
    list = []
    @user.top_level_groups.each do |group|
      list << group
      list << @user.groups.where(id: group.children.map(&:id)).order(:name)
    end
    list.flatten
  end

end
