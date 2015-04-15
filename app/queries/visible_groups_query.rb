class VisibleGroupsQuery
  def self.expand(group: nil, user: nil)
    groups = []
    ability = Ability.new(user)

    if ability.can?(:show, group)
      groups << group
      groups += group.subgroups.all.select{|g| ability.can?(:show, g) }
    end

    groups
  end
end
