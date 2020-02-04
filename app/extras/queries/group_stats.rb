class Queries::GroupStats
  def self.visits_count(group)
    GroupVisit.where(group_id: group.id).count
  end

  def self.thread_items_count(group)
    Discussion.where(group_id: group.id).sum(:items_count)
  end

  def self.discussions_count(group)
    Discussion.where(group_id: group.id).count
  end

  def self.polls_count(group)
    Poll.where(group_id: group.id).count
  end

  def self.visits_count_including_subgroups(group)
    OrganisationVisit.where(organisation_id: group.id).count
  end

  def self.thread_items_count_including_subgroups(group)
    Discussion.where(group_id: group.id_and_subgroup_ids).sum(:items_count)
  end

  def self.discussions_count_including_subgroups(group)
    Discussion.where(group_id: group.id_and_subgroup_ids).count
  end

  def self.polls_count_including_subgroups(group)
    Poll.where(group_id: group.id_and_subgroup_ids).count
  end

end
