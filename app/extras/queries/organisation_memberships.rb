class Queries::OrganisationMemberships
  def self.for(membership)
    Membership.where(group_id: relevant_group_ids_for(membership.group))
  end

  def self.relevant_group_ids_for(group)
    Group.where(id: group.id_and_subgroup_ids).map do |g|
      [g.discussions.pluck(:guest_group_id), g.polls.pluck(:guest_group_id), g.id]
    end.flatten
  end
end
